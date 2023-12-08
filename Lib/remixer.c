#include <stdio.h>
#include <stdint.h>
#include <string.h>

enum {
	CONFLICTTYPE_NONE,
	CONFLICTTYPE_DUPLICATE,
	CONFLICTTYPE_1CONTAINS2,
	CONFLICTTYPE_2CONTAINS1,
	CONFLICTTYPE_OVERLAP
};

typedef struct {
	const uint32_t startingOffsetfromBody;
	const uint32_t endingOffsetfromBody;
	const uint16_t key;
} __attribute__((packed)) info_t;

typedef struct {
	uint16_t initialIndex1;
	uint16_t initialIndex2;
	const uint16_t totalIndex;
	info_t *buffer;
} __attribute__((packed)) data_t;

typedef struct {
	uint32_t encryption;
	uint16_t fileSize;
	uint32_t bodySize;
} __attribute__((packed)) header_t;

typedef struct {
	uint32_t id;
	uint32_t offsetfrombody;
	uint32_t size;
} __attribute__((packed)) lookup_t;

#define ConflictDetected(CONFLICTTYPE) { \
	data->initialIndex2 = index2; \
	return CONFLICTTYPE; \
}

#define ConflictCheck() { \
	for (; index2 < totalIndex; index2++) { \
		if ((buffer1->startingOffsetfromBody == buffer2->startingOffsetfromBody) && (buffer2->endingOffsetfromBody == buffer1->endingOffsetfromBody)) { \
			/* Index2 was a duplicate of Index1 */ \
			ConflictDetected(CONFLICTTYPE_DUPLICATE) \
		} else if ((buffer1->startingOffsetfromBody <= buffer2->startingOffsetfromBody) && (buffer2->endingOffsetfromBody <= buffer1->endingOffsetfromBody)) { \
			/* Index1 was a container of Index2 */ \
			ConflictDetected(CONFLICTTYPE_1CONTAINS2) \
		} else if ((buffer2->startingOffsetfromBody <= buffer1->startingOffsetfromBody) && (buffer1->endingOffsetfromBody <= buffer2->endingOffsetfromBody)) { \
			/* Index2 was a container of Index1 */ \
			ConflictDetected(CONFLICTTYPE_2CONTAINS1) \
		} else if (((buffer2->startingOffsetfromBody <= buffer1->startingOffsetfromBody) && (buffer1->startingOffsetfromBody <  buffer2->endingOffsetfromBody)) \
				|| ((buffer2->startingOffsetfromBody <  buffer1->endingOffsetfromBody  ) && (buffer1->endingOffsetfromBody   <= buffer2->endingOffsetfromBody)) \
				|| ((buffer1->startingOffsetfromBody <= buffer2->startingOffsetfromBody) && (buffer2->startingOffsetfromBody <  buffer1->endingOffsetfromBody)) \
				|| ((buffer1->startingOffsetfromBody <  buffer2->endingOffsetfromBody  ) && (buffer2->endingOffsetfromBody   <= buffer1->endingOffsetfromBody))) { \
			/* file Overlap was detected, we escalate its garbage level */ \
			ConflictDetected(CONFLICTTYPE_OVERLAP) \
		} \
		buffer2++; /* next index2 */ \
	} \
}

uint8_t FileConflictChecker(data_t *data) {
	uint16_t index2, totalIndex;
	info_t *buffer, *buffer1, *buffer2;
	
			// avoid access overhead by saving them inside a local variable
	index2 = data->initialIndex2 + 1; // next index
	totalIndex = data->totalIndex;
	buffer = data->buffer;

	if (index2 >= totalIndex) {
			// new iteration
		data->initialIndex1++;
		index2 = 1;
			//
	}

	if (data->initialIndex1 < totalIndex-1) {
			//
		if ((index2 >= 2) && (index2 < totalIndex)) {
			buffer1 = &buffer[data->initialIndex1];
			buffer2 = &buffer[index2];
			ConflictCheck()
			data->initialIndex1++;
		}

		buffer1 = &buffer[data->initialIndex1];
		for (; data->initialIndex1 < totalIndex-1; data->initialIndex1++) {
			index2 = data->initialIndex1 + 1;
			buffer2 = &buffer[index2];
			ConflictCheck()
			buffer1++; // next index1
		}
	}

	data->initialIndex1 = totalIndex;
	data->initialIndex2 = 1;
	return CONFLICTTYPE_NONE;
}

uint32_t ReconstructMIX(void *source, void *destination, uint32_t destination_Body_MaxSize, uint16_t *lookupIndexes, uint16_t count) {
	lookup_t *source_LookupTable = source + sizeof(header_t);
	void *source_Body = (void*)source_LookupTable + ((*((uint16_t*)(source + 4))) * sizeof(lookup_t));
	
	lookup_t *destination_LookupTable_Seeker = destination + sizeof(header_t); // lookup info of lmd file
	uint32_t destination_Body_CurrentSize = destination_LookupTable_Seeker->size; // ptr to the end of the lmd file
	if (destination_Body_MaxSize < destination_Body_CurrentSize)
		return 0; // error: no more space for the body
	uint32_t destination_Body_RemainingSize = destination_Body_MaxSize - destination_Body_CurrentSize;

	destination_LookupTable_Seeker++; // start at destination lookup index 1 since index 0 is the lmd file
	void *destination_Body = (void*)destination_LookupTable_Seeker + (count * sizeof(lookup_t)); // count didn't include the lmd file, but the seeker already included it.
	void *destination_Body_Seeker = destination_Body + destination_Body_CurrentSize; // start the end of the lmd file

	for (uint16_t i = 0; i < count; i++) {
		lookup_t *lookupInfo = &source_LookupTable[lookupIndexes[i]];
		if (destination_Body_RemainingSize < lookupInfo->size)
			return 0; // error: no more space for the body
		destination_LookupTable_Seeker->id = lookupInfo->id;
		destination_LookupTable_Seeker->offsetfrombody = destination_Body_CurrentSize; // the offset where this file is located at the body is equal to the current body size
		destination_LookupTable_Seeker->size = lookupInfo->size;
		memcpy(destination_Body_Seeker, source_Body + lookupInfo->offsetfrombody, lookupInfo->size);
		destination_LookupTable_Seeker++; // next index
		destination_Body_Seeker += lookupInfo->size; // ptr to the EOF
		destination_Body_CurrentSize += lookupInfo->size; // include the file size to the overall body size
		destination_Body_RemainingSize -= lookupInfo->size;
	}

	((header_t*)destination)->encryption = 0; // no encryption
	((header_t*)destination)->fileSize = count + 1; // indexedfiles + lmd
	((header_t*)destination)->bodySize = destination_Body_CurrentSize; // destination_Body_CurrentSize = destination_Body_Seeker - destination_Body
	return destination_Body_Seeker - destination; // return file size
}
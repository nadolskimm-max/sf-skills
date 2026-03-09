---
name: sf-file-management
description: >
  Manages Salesforce files including ContentDocument, ContentVersion,
  file uploads, attachments, and external storage. Use when uploading
  files, linking files to records, querying file metadata, managing
  file permissions, or migrating from Attachments to Files. Do NOT use
  for general data operations (use sf-data) or metadata XML (use sf-metadata).
---

# File Management

## Core Responsibilities

1. Upload and manage files (ContentDocument / ContentVersion)
2. Link files to records (ContentDocumentLink)
3. Query file metadata and content
4. Manage file permissions and sharing
5. Migrate legacy Attachments to Files

## File Object Model

```
ContentDocument (file container)
├── ContentVersion (file versions — one per revision)
│   ├── VersionData (actual file binary)
│   ├── Title, FileExtension, ContentSize
│   └── PathOnClient (original filename)
└── ContentDocumentLink (links file to records)
    ├── LinkedEntityId (Account, Case, etc.)
    ├── ShareType (V=Viewer, C=Collaborator, I=Inferred)
    └── Visibility (AllUsers, InternalUsers, SharedUsers)
```

## Upload File (Apex)

```apex
public class FileService {
    public static Id uploadFile(Id parentId, String fileName, Blob fileBody) {
        ContentVersion cv = new ContentVersion(
            Title = fileName.substringBeforeLast('.'),
            PathOnClient = fileName,
            VersionData = fileBody,
            FirstPublishLocationId = parentId
        );
        insert cv;
        return cv.Id;
    }

    public static void linkFileToRecord(Id contentDocumentId, Id recordId) {
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = contentDocumentId,
            LinkedEntityId = recordId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;
    }
}
```

## Query Files

```sql
-- Files linked to a record
SELECT ContentDocument.Title, ContentDocument.FileExtension,
       ContentDocument.ContentSize, ContentDocument.LatestPublishedVersionId
FROM ContentDocumentLink
WHERE LinkedEntityId = :recordId

-- Latest version of all files
SELECT Id, Title, FileExtension, ContentSize, CreatedDate,
       ContentDocumentId, VersionNumber
FROM ContentVersion
WHERE IsLatest = true
ORDER BY CreatedDate DESC

-- File content (download)
SELECT Id, Title, VersionData
FROM ContentVersion
WHERE Id = :versionId
```

## LWC File Upload

```html
<template>
    <lightning-file-upload
        label="Attach Files"
        name="fileUploader"
        record-id={recordId}
        accept={acceptedFormats}
        onuploadfinished={handleUploadFinished}
        multiple>
    </lightning-file-upload>
</template>
```

```javascript
import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FileUploader extends LightningElement {
    @api recordId;
    acceptedFormats = ['.pdf', '.png', '.jpg', '.doc', '.docx', '.xlsx'];

    handleUploadFinished(event) {
        const files = event.detail.files;
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: files.length + ' file(s) uploaded',
            variant: 'success'
        }));
    }
}
```

## File Size Limits

| Context | Max Size |
|---|---|
| Single file upload (UI) | 2 GB |
| Apex ContentVersion insert | 37.5 MB (body in transaction) |
| REST API file upload | 2 GB |
| Email attachment | 25 MB |
| Apex Blob variable | 12 MB (heap limit) |

## Attachment to Files Migration

```apex
public class AttachmentMigrationBatch implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name, Body, ContentType, ParentId
            FROM Attachment
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Attachment> scope) {
        List<ContentVersion> files = new List<ContentVersion>();
        for (Attachment att : scope) {
            files.add(new ContentVersion(
                Title = att.Name,
                PathOnClient = att.Name,
                VersionData = att.Body,
                FirstPublishLocationId = att.ParentId
            ));
        }
        insert files;
    }

    public void finish(Database.BatchableContext bc) {}
}
```

## Anti-Patterns

| Anti-Pattern | Fix |
|---|---|
| Using `Attachment` object (legacy) | Use ContentVersion / ContentDocument |
| Large file in Apex Blob variable | Use REST API for files > 12 MB |
| No ShareType on ContentDocumentLink | Always set ShareType (V, C, or I) |
| Querying VersionData in bulk | Query metadata first, download individually |

## Cross-Skill References

- For Apex file handling: see **sf-apex**
- For LWC upload components: see **sf-lwc**
- For batch migration: see **sf-async-patterns**
- For file security: see **sf-security**

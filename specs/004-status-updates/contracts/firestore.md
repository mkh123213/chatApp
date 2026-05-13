# Contract — Firestore

## Collection: `statuses`

### Document shape (canonical example — image)

```json
{
  "id": "abc123XYZ",
  "userId": "uid_author_1",
  "userName": "Sara M.",
  "userEmail": "sara@example.com",
  "userPhotoUrl": "https://.../sara.jpg",
  "type": "image",
  "mediaUrl": "https://<supabase>/storage/v1/object/public/statuses/uid_author_1/1714896000000_a1b2.jpg",
  "storagePath": "statuses/uid_author_1/1714896000000_a1b2.jpg",
  "text": null,
  "backgroundColor": null,
  "viewers": ["uid_viewer_1", "uid_viewer_2"],
  "createdAt": "<Timestamp>",
  "expiresAt": "<Timestamp>"
}
```

### Document shape (canonical example — text)

```json
{
  "id": "def456UVW",
  "userId": "uid_author_2",
  "userName": "Omar K.",
  "userEmail": "omar@example.com",
  "userPhotoUrl": null,
  "type": "text",
  "mediaUrl": null,
  "storagePath": null,
  "text": "Coffee time ☕",
  "backgroundColor": 4280391411,
  "viewers": [],
  "createdAt": "<Timestamp>",
  "expiresAt": "<Timestamp>"
}
```

## Operations

| Operation                | Method                                            | Notes |
|--------------------------|---------------------------------------------------|-------|
| Mint ID                  | `FirebaseFirestore.instance.collection('statuses').doc().id` | Only sanctioned direct use; one line in data source |
| Create                   | `DataBaseService.setData(collection: 'statuses', docId: id, data: status.toJson())` | After Supabase upload (image) |
| Watch contacts' active   | `DataBaseService.streamCollection(...).where('userId', whereIn: chunk).where('expiresAt', isGreaterThan: Timestamp.now()).orderBy('expiresAt').orderBy('createdAt', descending: true)` | Chunk `whereIn` ≤ 30 |
| Watch own active         | Same with `where('userId', isEqualTo: currentUid)` | |
| Mark viewed              | `DataBaseService.updateData(collection: 'statuses', docId: id, data: {'viewers': FieldValue.arrayUnion([viewerUid])})` | Idempotent |
| Delete                   | `DataBaseService.deleteData(collection: 'statuses', docId: id)` | After Supabase remove |

## Indexes (composite)

1. `userId ASC, expiresAt ASC, createdAt DESC`
2. `expiresAt ASC, createdAt DESC` (used with `whereIn(userId)`)

## Security Rules (sketch — to be added to `firestore.rules`)

```text
match /statuses/{statusId} {
  allow read:   if request.auth != null;
  allow create: if request.auth != null
                && request.resource.data.userId == request.auth.uid;
  allow delete: if request.auth != null
                && resource.data.userId == request.auth.uid;
  // Allow updating ONLY the viewers array, ONLY adding self.
  allow update: if request.auth != null
                && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['viewers'])
                && request.auth.uid in request.resource.data.viewers
                && request.resource.data.viewers.size() == resource.data.viewers.size() + 1;
}
```

Rule deployment is tracked separately and out of plan scope; documented for completeness.

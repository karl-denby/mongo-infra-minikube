#!/bin/bash

# Prompt the user for input
read -p "Enter the path to your mongodump directory, for example ~/Downloads/mongodump: " DUMP_DIR
DUMP_DIR="${DUMP_DIR/#\~/$HOME}"  # Replace ~ with $HOME if present
read -p "Enter your full MongoDB Atlas connection URI, for example mongodb+srv://<username>:<password>@<cluster-url>/?retryWrites=true&w=majority
: " MONGO_URI

# Ensure the admin directory is not included in the restoration
if [ -d "$DUMP_DIR/admin" ]; then
    echo "Removing admin directory from the dump to avoid restoring users, roles, or credentials..."
    rm -rf "$DUMP_DIR/admin"
fi

# Restore the entire dump to the new database without specifying collection names
mongorestore --uri="$MONGO_URI" --dir="$DUMP_DIR"  --verbose --drop 
# Create the Vector Index using mongosh
cat <<EOF | mongosh "$MONGO_URI"
use MAAP
db.embedded_content.createSearchIndex(
  "vector_index", 
  "vectorSearch", 
  {
    "fields": [
      {
        "type": "vector",
        "path": "embedding",
        "numDimensions": 768,
        "similarity": "cosine"
      }
    ]
  }
)
EOF
# Verify the restoration
if [ $? -eq 0 ]; then
  echo "Restore to MAAP completed successfully."
else
  echo "Restore failed."
  exit 1
fi
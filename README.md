# WordTree Scripts API

This is the Scripts API server for WordTree. It provides access to long-running
scripts and command-line tools in the WordTree API.

NOTE: This is not a client library (in the software sense). This is the server
portion that we host on our end, so you probably don't need it.

## Usage

This is likely to change frequently, but at the time of writing, you can access
these API endpoints:

- Start a "count" job (for testing):

    http://api.wordtree.org/script/count

- Check on the status of the job:

    http://api.wordtree.org/script/status/5dcadbf8-9274-4db9-9e38-a7fdea1fc264

- Show a live update of the status of the job:

    http://api.wordtree.org/script/status/5dcadbf8-9274-4db9-9e38-a7fdea1fc264/live

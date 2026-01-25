# MeetPoll Messages Extension

This repo contains a basic iMessage extension for creating a meeting poll with a name, time, and location options.

## How to use in Xcode
1. Create a new Xcode project: **iOS > App** (Swift, SwiftUI).
2. Add a new target: **Messages Extension**.
3. Replace the generated files in the app and extension targets with the files in this repo:
   - `MeetPoll/` for the container app target
   - `MeetPollMessages/` for the Messages extension target
4. Ensure both targets have `MapKit` and `Messages` frameworks linked.
5. Build and run on a device or simulator with Messages.

The Messages extension UI lets you:
- Name a meeting
- Pick a date/time
- Add place options via MapKit search
- Open a selected place in Apple Maps
- Send the poll as an iMessage

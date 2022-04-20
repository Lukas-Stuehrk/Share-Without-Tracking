# Rules - Shared package to exchange the URL replacement rules between the app and the share extension.

The main functionality of `Share Without Tracking` is implemented in a sharing extension. But the sharing extension
applies replacement rules which are defined by the user in the actual iOS app. This Swift package is used by the app
_and_ the sharing extension to write, read, and apply replacement rules.

The data of the created rules is written in an app group which is used by both the iOS app and the sharing extension.

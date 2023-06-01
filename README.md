# flutter_camera_rt

A sample project whose objective is to access realtime camera frames, convert them and make them accessible to the flutter engine.
It accesses camera frames inside the flutter code with startCameraStream and then sends them to the java code to convert them to jpg.

To start the project : 
    flutter run

If you're seeing a white screen, just tap the abc icon on the bottom left.

## Why ?

I tried to do it simply in dart, but the performance was very very bad. So I search for a way to improve it, and the way I found was to convert the frames outside the flutter engine and convert them there and then send them back in the good format.
It could be applied to many more problems in which the Flutter engine isnt strong or fast enough.

## Improvements

1. State management
2. Camera controls
3. Interface


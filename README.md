# markerx

Hi Guys, 


based off of [https://github.com/KanarekApp/flutter_map_fast_markers/tree/canary](url) I have written a new `MarkerX`  class that can load huge number of marker points and show them on the map. In my example i am using a QuadTree to better sort the markers and using the bounds of the visible screen to populate the markers. simple logic and the draw on canvas feature that the original author uses (for now) [ will try with prebuilt markers in future] 

Initially I tried to use zoom and populate markers based off of it but It would only do so where my screen was visible when i scrolled up down right left.. nothing.[ there is a markerzoom class if you want to try it out]

So, I decided to go with bounds instead.
I feel it's doing a good job, surely will lag a bit when it has 30k markers in memory, However I am not sure if its just a placebo or is actually working, upto you guys to tell.

I have tried it with few markers may be 5000, works smooth.

Apologies, my knowledge is limited and this is as far as I could go, hopefully one of you can look into this matter and let us know if this is any good ?

If it works i would like to create a plugin.
Never created a plugin so.. yeah!. Hopefully to learn from one of you on how to do it ?

If its similar to what we have now with the default marker, please disregards. Just a poor attempt I guess..

If not then cool .. just wanted to contribute.. :P

this is the repo, feel free to try [https://github.com/jesussmile/markerx](url)

https://user-images.githubusercontent.com/11044978/230025056-f118d3ba-21cd-471b-8324-b65f6d9aa36b.mp4


Note- I dont know anyting about PR or how to incorporate it, so.. if you make one tell me what to do next .. haha.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

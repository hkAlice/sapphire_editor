'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "9ebb0d1740cedb9b9cbc6936cf9d1687",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"favicon.png": "bd2ad0cb1d9ad14706bf813c52add412",
"icons/Icon-maskable-512.png": "a4ca2b855e0674a1cbda3ef28803d07d",
"icons/Icon-maskable-192.png": "d8e384a36b723b30075a93808fb50b35",
"icons/Icon-512.png": "a4ca2b855e0674a1cbda3ef28803d07d",
"icons/Icon-192.png": "d8e384a36b723b30075a93808fb50b35",
"manifest.json": "753333f77367aff19c40e20725148d3d",
"version.json": "eee017ec81ca7b08cd40d07447f6878c",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"main.dart.js": "8279668b8f4667ac72601b12be6e55ed",
"index.html": "166dc031f2be2706b849b48147f14db6",
"/": "166dc031f2be2706b849b48147f14db6",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/iconsax_flutter/fonts/FlutterIconsax.ttf": "83c878235f9c448928034fe5bcba1c8a",
"assets/FontManifest.json": "7df10702a8c60a62e6694f43081d46e7",
"assets/NOTICES": "58525b31783cab5337517e738189ac16",
"assets/AssetManifest.json": "0c7ebc58822e6ec82c139c1fede1b852",
"assets/AssetManifest.bin": "68551bcaa5126ac595f0130aa5706d93",
"assets/AssetManifest.bin.json": "5b2238af8f74b2c09a169bfbef7b404e",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/fonts/MaterialIcons-Regular.otf": "298403ae3e3d085add2541d3c9d4ed66",
"assets/assets/images/sapphire_icon.png": "5e5b6d4a74cdd8ac0f8a8072fad73bf3",
"assets/assets/images/icon_trials_rounded.png": "b123085586e6e5783aa502aaf6cce006",
"assets/assets/images/sapphire_logo.png": "28f8e87cea23ba7f0114f2f790e9eb68",
"assets/assets/images/icon_trials.png": "d4c67371a371d4e08ef9e18bd9bb4989",
"assets/assets/images/icon_loottables_rounded.png": "5d118f8c6dfe7aadd53c17adf393726e",
"assets/assets/images/loading/loading_06.png": "bc669e503760772fe3e6910238c076e2",
"assets/assets/images/loading/loading_05.png": "63bdfc99f21b59fcb82f24fb0e5a3af0",
"assets/assets/images/loading/loading_09.png": "41875c17af9a9966dde94a9c38b2b3c8",
"assets/assets/images/loading/loading_11.png": "c6433fdbbd0a021b91904549d5e6ca45",
"assets/assets/images/loading/loading_08.png": "03ffa16b5c1fb4628401d2d4e90923f8",
"assets/assets/images/loading/loading_00.png": "844361196975d4f54bced85d9e6448b3",
"assets/assets/images/loading/loading_02.png": "3a4505e7095059cac569c0c16072f27a",
"assets/assets/images/loading/loading_03.png": "bc7711ced6b5330b025b033f76cd7349",
"assets/assets/images/loading/loading_10.png": "a72422e13bb40a6c5cdfb627cf5441f8",
"assets/assets/images/loading/loading_01.png": "4e4999095116ac078d113a96e651d44f",
"assets/assets/images/loading/loading_07.png": "11e641dc9ae8e31349a48ce93fbe8e75",
"assets/assets/images/loading/loading_04.png": "199aedaf1859e93791a1983b365d3edc",
"assets/assets/images/app.png": "71387545e5fe11f75445e26488f4cb03",
"assets/assets/data/ItemMinimal.json": "a1ac1930e8d815228d2672a0de53b0e7"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}

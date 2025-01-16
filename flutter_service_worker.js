'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"icons/Icon-maskable-192.png": "d8e384a36b723b30075a93808fb50b35",
"icons/Icon-maskable-512.png": "a4ca2b855e0674a1cbda3ef28803d07d",
"icons/Icon-512.png": "a4ca2b855e0674a1cbda3ef28803d07d",
"icons/Icon-192.png": "d8e384a36b723b30075a93808fb50b35",
"assets/assets/images/icon_trials.png": "d4c67371a371d4e08ef9e18bd9bb4989",
"assets/assets/images/sapphire_logo.png": "28f8e87cea23ba7f0114f2f790e9eb68",
"assets/assets/images/app.png": "71387545e5fe11f75445e26488f4cb03",
"assets/assets/images/icon_trials_rounded.png": "b123085586e6e5783aa502aaf6cce006",
"assets/assets/images/sapphire_icon.png": "5e5b6d4a74cdd8ac0f8a8072fad73bf3",
"assets/assets/images/loading/loading_06.png": "bc669e503760772fe3e6910238c076e2",
"assets/assets/images/loading/loading_11.png": "c6433fdbbd0a021b91904549d5e6ca45",
"assets/assets/images/loading/loading_05.png": "63bdfc99f21b59fcb82f24fb0e5a3af0",
"assets/assets/images/loading/loading_04.png": "199aedaf1859e93791a1983b365d3edc",
"assets/assets/images/loading/loading_00.png": "844361196975d4f54bced85d9e6448b3",
"assets/assets/images/loading/loading_03.png": "bc7711ced6b5330b025b033f76cd7349",
"assets/assets/images/loading/loading_08.png": "03ffa16b5c1fb4628401d2d4e90923f8",
"assets/assets/images/loading/loading_07.png": "11e641dc9ae8e31349a48ce93fbe8e75",
"assets/assets/images/loading/loading_10.png": "a72422e13bb40a6c5cdfb627cf5441f8",
"assets/assets/images/loading/loading_02.png": "3a4505e7095059cac569c0c16072f27a",
"assets/assets/images/loading/loading_01.png": "4e4999095116ac078d113a96e651d44f",
"assets/assets/images/loading/loading_09.png": "41875c17af9a9966dde94a9c38b2b3c8",
"assets/AssetManifest.bin": "e7f5711208d317a7b121e9b3c0ae7685",
"assets/NOTICES": "b893aed4ab6c9f79cf9f25f67691527a",
"assets/AssetManifest.json": "57e6b5de55c8d1f4e1e4430b89776152",
"assets/fonts/MaterialIcons-Regular.otf": "2d3164f8c86bfcd79a7862749413bdd2",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/packages/iconsax_flutter/fonts/FlutterIconsax.ttf": "83c878235f9c448928034fe5bcba1c8a",
"assets/FontManifest.json": "7df10702a8c60a62e6694f43081d46e7",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin.json": "966a44413c24d4d7a5dc1e46a913c5bc",
"version.json": "eee017ec81ca7b08cd40d07447f6878c",
"manifest.json": "753333f77367aff19c40e20725148d3d",
"canvaskit/chromium/canvaskit.js.symbols": "e115ddcfad5f5b98a90e389433606502",
"canvaskit/chromium/canvaskit.wasm": "ea5ab288728f7200f398f60089048b48",
"canvaskit/chromium/canvaskit.js": "b7ba6d908089f706772b2007c37e6da4",
"canvaskit/skwasm.js": "ac0f73826b925320a1e9b0d3fd7da61c",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"canvaskit/skwasm.js.symbols": "96263e00e3c9bd9cd878ead867c04f3c",
"canvaskit/canvaskit.js.symbols": "efc2cd87d1ff6c586b7d4c7083063a40",
"canvaskit/skwasm.wasm": "828c26a0b1cc8eb1adacbdd0c5e8bcfa",
"canvaskit/canvaskit.wasm": "e7602c687313cfac5f495c5eac2fb324",
"canvaskit/canvaskit.js": "26eef3024dbc64886b7f48e1b6fb05cf",
"index.html": "003c13e6ba4a7a015cd7858237d59f0d",
"/": "003c13e6ba4a7a015cd7858237d59f0d",
"flutter.js": "4b2350e14c6650ba82871f60906437ea",
"favicon.png": "bd2ad0cb1d9ad14706bf813c52add412",
"flutter_bootstrap.js": "9678624e54167b4dd57f4e625531f0b8",
"main.dart.js": "49dcd7a40091dc1aaf2cb05a0b77ff95"};
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
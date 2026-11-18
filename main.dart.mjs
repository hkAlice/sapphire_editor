// Compiles a dart2wasm-generated main module from `source` which can then
// be instantiated via the `instantiate` method.
//
// `source` needs to be a `Response` object (or promise thereof) e.g. created
// via the `fetch()` JS API.
export async function compileStreaming(source) {
  const builtins = {builtins: ['js-string'], importedStringConstants: ''};
  return new CompiledApp(
      await _compileStreaming(source, builtins), builtins);
}

// Compiles a dart2wasm-generated wasm module from `bytes` which is then
// instantiable via the `instantiate` method.
export async function compile(bytes) {
  const builtins = {builtins: ['js-string'], importedStringConstants: ''};
  return new CompiledApp(await WebAssembly.compile(bytes, builtins), builtins);
}

let _isCompileStreamingSupported;
async function _compileStreaming(source, builtins) {
  _isCompileStreamingSupported ??= WebAssembly.compileStreaming(
    new Response(
      new Uint8Array([0,97,115,109,1,0,0,0,1,4,1,96,0,0,2,23,1,14,119,97,115,109,58,106,115,45,115,116,114,105,110,103,4,99,97,115,116,0,0]),
      {headers: {'Content-Type': 'application/wasm'}},
    ),
    builtins,
  ).then(() => false, (e) => e instanceof WebAssembly.CompileError);
  if (await _isCompileStreamingSupported) {
    return WebAssembly.compileStreaming(source, builtins);
  }
  return WebAssembly.compile(await (await source).arrayBuffer(), builtins);
}

class CompiledApp {
  constructor(module, builtins) {
    this.module = module;
    this.builtins = builtins;
  }

  // The second argument is an options object containing:
  // `loadDeferredModules` is a JS function that takes an array of module names
  //   matching wasm files produced by the dart2wasm compiler. It also takes a
  //   callback that should be invoked for each loaded module with 2 arguments:
  //   (1) the module name, (2) the loaded module in a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`. The callback
  //   returns a Promise that resolves when the module is instantiated.
  //   loadDeferredModules should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  // `loadDeferredId` is a JS function that takes load ID produced by the
  //   compiler when the `use-load-ids` option is passed. Each load ID maps to
  //   one or more wasm files as specified in the emitted JSON file. It also
  //   takes a callback that should be invoked for each loaded module with 2
  //   arguments: (1) the module name, (2) the loaded module in a format
  //   supported by `WebAssembly.compile` or `WebAssembly.compileStreaming`.
  //   The callback returns a Promise that resolves when the module is
  //   instantiated.
  //   loadDeferredId should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  async instantiate(additionalImports, {loadDeferredModules, loadDeferredId} = {}) {
    let dartInstance;

    // Prints to the console
    function printToConsole(value) {
      if (typeof dartPrint == "function") {
        dartPrint(value);
        return;
      }
      if (typeof console == "object" && typeof console.log != "undefined") {
        console.log(value);
        return;
      }
      if (typeof print == "function") {
        print(value);
        return;
      }

      throw "Unable to print message: " + value;
    }

    // A special symbol attached to functions that wrap Dart functions.
    const jsWrappedDartFunctionSymbol = Symbol("JSWrappedDartFunction");

    function finalizeWrapper(dartFunction, wrapped) {
      wrapped.dartFunction = dartFunction;
      wrapped[jsWrappedDartFunctionSymbol] = true;
      return wrapped;
    }

    // Imports
    const dart2wasm = {
            AB: x0 => new Int16Array(x0),
      AC: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
      AD: (x0,x1,x2) => x0.addEventListener(x1,x2),
      AE: (o, i) => o[i],
      AF: x0 => x0.tiltY,
      AG: () => globalThis.Intl,
      AH: x0 => x0.selectionEnd,
      AI: x0 => x0.disabled,
      AJ: (x0,x1) => x0.send(x1),
      AK: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      AL: (x0,x1) => new OffscreenCanvas(x0,x1),
      B: s => printToConsole(s),
      BB: x0 => new Uint16Array(x0),
      BC: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
      BD: (x0,x1,x2) => x0.setAttribute(x1,x2),
      BE: o => o.length,
      BF: x0 => x0.tiltX,
      BG: (x0,x1) => x0.segment(x1),
      BH: (x0,x1) => { x0.name = x1 },
      BI: (x0,x1) => { x0.min = x1 },
      BJ: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      BK: (x0,x1) => x0.getAll(x1),
      BL: x0 => x0.assetBase,
      C: Function.prototype.call.bind(Number.prototype.toString),
      CB: x0 => new Int32Array(x0),
      CC: (x0,x1) => x0.querySelector(x1),
      CD: (x0,x1) => x0.closest(x1),
      CE: o => {
        if (o === undefined) return 1;
        var type = typeof o;
        if (type === 'boolean') return 2;
        if (type === 'number') return 3;
        if (type === 'string') return 4;
        if (o instanceof Array) return 5;
        if (ArrayBuffer.isView(o)) {
          if (o instanceof Int8Array) return 6;
          if (o instanceof Uint8Array) return 7;
          if (o instanceof Uint8ClampedArray) return 8;
          if (o instanceof Int16Array) return 9;
          if (o instanceof Uint16Array) return 10;
          if (o instanceof Int32Array) return 11;
          if (o instanceof Uint32Array) return 12;
          if (o instanceof Float32Array) return 13;
          if (o instanceof Float64Array) return 14;
          if (o instanceof DataView) return 15;
        }
        if (o instanceof ArrayBuffer) return 16;
        // Feature check for `SharedArrayBuffer` before doing a type-check.
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
            return 17;
        }
        if (o instanceof Promise) return 18;
        return 19;
      },
      CF: x0 => x0.pointerType,
      CG: x0 => x0.index,
      CH: (x0,x1) => { x0.placeholder = x1 },
      CI: (x0,x1) => { x0.max = x1 },
      CJ: (x0,x1,x2,x3) => x0.removeEventListener(x1,x2,x3),
      CK: x0 => x0.value,
      CL: x0 => x0.loader,
      D: Function.prototype.call.bind(BigInt.prototype.toString),
      DB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      DC: (x0,x1) => x0.item(x1),
      DD: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      DE: x0 => x0.language,
      DF: x0 => x0.pointerId,
      DG: x0 => x0.next(),
      DH: (x0,x1) => { x0.autocomplete = x1 },
      DI: (x0,x1) => { x0.disabled = x1 },
      DJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      DK: x0 => x0.openCursor(),
      DL: () => globalThis._flutter,
      E: (exn) => {
        let stackString = exn.toString();
        let frames = stackString.split('\n');
        let drop = 4;
        if (frames[0].startsWith('Error')) {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      EB: x0 => new Uint32Array(x0),
      EC: x0 => x0.length,
      ED: (handle) => clearTimeout(handle),
      EE: (x0,x1,x2,x3) => x0.register(x1,x2,x3),
      EF: x0 => x0.getCoalescedEvents(),
      EG: x0 => x0.value,
      EH: (x0,x1) => { x0.type = x1 },
      EI: (x0,x1) => { x0.scrollLeft = x1 },
      EJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      EK: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      F: () => new Error().stack,
      FB: x0 => new Float32Array(x0),
      FC: (x0,x1) => x0.querySelectorAll(x1),
      FD: x0 => x0.maxTouchPoints,
      FE: () => globalThis.window.FinalizationRegistry,
      FF: s => s.trimLeft(),
      FG: x0 => x0.done,
      FH: (x0,x1) => { x0.name = x1 },
      FI: (x0,x1) => { x0.spellcheck = x1 },
      FJ: x0 => x0.statusText,
      FK: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      G: s => JSON.stringify(s),
      GB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      GC: (x0,x1) => x0.getAttribute(x1),
      GD: x0 => x0.platform,
      GE: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      GF: s => s.toUpperCase(),
      GG: (o, m, a) => o[m].apply(o, a),
      GH: (x0,x1) => { x0.placeholder = x1 },
      GI: (x0,x1) => { x0.disabled = x1 },
      GJ: x0 => x0.status,
      GK: (x0,x1) => { x0.onerror = x1 },
      H: Function.prototype.call.bind(Number.prototype.toString),
      HB: x0 => new Float64Array(x0),
      HC: x0 => x0.remove(),
      HD: s => new Date(s * 1000).getTimezoneOffset() * 60,
      HE: x0 => new window.FinalizationRegistry(x0),
      HF: (x0,x1) => x0[x1],
      HG: x0 => x0.iterator,
      HH: (x0,x1) => { x0.scrollTop = x1 },
      HI: (o, offsetInBytes, lengthInBytes) => {
        var dst = new ArrayBuffer(lengthInBytes);
        new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
        return new DataView(dst);
      },
      HJ: x0 => x0.responseURL,
      HK: x0 => x0.error,
      I: Function.prototype.call.bind(String.prototype.indexOf),
      IB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF64ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      IC: (x0,x1) => x0.appendChild(x1),
      ID: Date.now,
      IE: (x0,x1) => x0.unregister(x1),
      IF: x0 => x0.length,
      IG: () => globalThis.Symbol,
      IH: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      II: (a, s, e) => a.slice(s, e),
      IJ: x0 => x0.response,
      IK: (x0,x1) => { x0.onsuccess = x1 },
      J: (s, p, i) => s.lastIndexOf(p, i),
      JB: x0 => new ArrayBuffer(x0),
      JC: (x0,x1) => x0.append(x1),
      JD: (x0,x1) => x0.contains(x1),
      JE: x0 => x0.preventDefault(),
      JF: (x0,x1) => x0.exec(x1),
      JG: (x0,x1) => new Intl.Segmenter(x0,x1),
      JH: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      JI: (x0,x1,x2) => x0.set(x1,x2),
      JJ: x0 => x0.getAllResponseHeaders(),
      JK: x0 => x0.continue(),
      K: (exn) => {
        if (exn instanceof Error) {
          return exn.stack;
        } else {
          return null;
        }
      },
      KB: (x0,x1,x2) => new Uint8Array(x0,x1,x2),
      KC: (x0,x1,x2,x3) => x0.setProperty(x1,x2,x3),
      KD: (decoder, codeUnits) => decoder.decode(codeUnits),
      KE: x0 => x0.parent,
      KF: x0 => x0.index,
      KG: x0 => x0.Segmenter,
      KH: s => {
        if (/[[\]{}()*+?.\\^$|]/.test(s)) {
            s = s.replace(/[[\]{}()*+?.\\^$|]/g, '\\$&');
        }
        return s;
      },
      KI: x0 => x0.close(),
      KJ: (x0,x1) => { x0.withCredentials = x1 },
      KK: x0 => x0.result,
      L: o => o === undefined,
      LB: (x0,x1,x2) => new DataView(x0,x1,x2),
      LC: x0 => x0.style,
      LD: () => new TextDecoder("utf-8", {fatal: true}),
      LE: x0 => x0.timeStamp,
      LF: x0 => x0.flags,
      LG: x0 => x0.buffer,
      LH: x0 => x0.keyCode,
      LI: x0 => x0.height,
      LJ: (x0,x1) => { x0.responseType = x1 },
      LK: x0 => x0.target,
      M: o => String(o),
      MB: (o, p) => o[p],
      MC: x0 => x0.debugShowSemanticsNodes,
      MD: () => new TextDecoder("utf-8", {fatal: false}),
      ME: (x0,x1) => x0.hasAttribute(x1),
      MF: (a, s) => a.join(s),
      MG: x0 => x0.wasmMemory,
      MH: (x0,x1) => x0.scrollIntoView(x1),
      MI: x0 => x0.width,
      MJ: (x0,x1) => x0.getRandomValues(x1),
      MK: (x0,x1,x2) => x0.transaction(x1,x2),
      N: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      NB: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      NC: o => o,
      ND: (a, i, v) => a[i] = v,
      NE: x0 => x0.type,
      NF: (x0,x1) => x0.error(x1),
      NG: () => globalThis.window._flutter_skwasmInstance,
      NH: x0 => x0.multiViewEnabled,
      NI: (x0,x1,x2,x3,x4,x5) => x0.createImageBitmap(x1,x2,x3,x4,x5),
      NJ: () => globalThis.crypto,
      NK: (x0,x1) => x0.objectStore(x1),
      O: (x0,x1) => x0.didCreateEngineInitializer(x1),
      OB: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      OC: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'boolean') return 1;
        return 2;
      },
      OD: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI8ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      OE: (x0,x1) => x0.getModifierState(x1),
      OF: () => globalThis.console,
      OG: () => new TextDecoder(),
      OH: (x0,x1) => x0.replaceWith(x1),
      OI: (x0,x1) => x0.createImageBitmap(x1),
      OJ: l => new DataView(new ArrayBuffer(l)),
      OK: (x0,x1) => x0.getAllKeys(x1),
      P: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      PB: o => o.byteOffset,
      PC: (x0,x1) => x0.warn(x1),
      PD: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      PE: x0 => x0.buttons,
      PF: s => s.trimRight(),
      PG: (map, o, v) => map.set(o, v),
      PH: (x0,x1) => { x0.className = x1 },
      PI: x0 => new Blob(x0),
      PJ: x0 => x0.pop(),
      PK: x0 => x0.key,
      Q: (wasmFunction,f) => finalizeWrapper(f, function() { return wasmFunction(f,arguments.length) }),
      QB: o => o.buffer,
      QC: x0 => x0.console,
      QD: (s) => +s,
      QE: x0 => x0.ctrlKey,
      QF: x0 => x0.blur(),
      QG: (map, o) => map.get(o),
      QH: (x0,x1) => { x0.tabIndex = x1 },
      QI: x0 => x0.close(),
      QJ: x0 => x0.abort(),
      QK: (o, t) => typeof o === t,
      R: (x0,x1) => ({initializeEngine: x0,autoStart: x1}),
      RB: Function.prototype.call.bind(DataView.prototype.getUint8),
      RC: () => globalThis.window,
      RD: s => {
        if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
          return NaN;
        }
        return parseFloat(s);
      },
      RE: x0 => x0.getBoundingClientRect(),
      RF: x0 => x0.button,
      RG: () => new WeakMap(),
      RH: (x0,x1) => { x0.action = x1 },
      RI: x0 => x0.naturalHeight,
      RJ: x0 => ({type: x0}),
      RK: x0 => x0.close(),
      S: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      SB: (b, o) => new DataView(b, o),
      SC: (o, c) => o instanceof c,
      SD: s => s.trim(),
      SE: x0 => x0.y,
      SF: (x0,x1) => x0.prepend(x1),
      SG: (d, digits) => d.toFixed(digits),
      SH: (x0,x1) => { x0.method = x1 },
      SI: x0 => x0.naturalWidth,
      SJ: (x0,x1) => new Blob(x0,x1),
      SK: (x0,x1) => x0.delete(x1),
      T: x0 => new Promise(x0),
      TB: (b, o, l) => new DataView(b, o, l),
      TC: (string, token) => string.split(token),
      TD: x0 => x0.classList,
      TE: x0 => x0.x,
      TF: x0 => x0.parentElement,
      TG: x0 => x0.maxHeight,
      TH: (x0,x1) => { x0.noValidate = x1 },
      TI: (x0,x1) => { x0.src = x1 },
      TJ: x0 => globalThis.URL.createObjectURL(x0),
      TK: (x0,x1,x2) => x0.put(x1,x2),
      U: (x0,x1,x2) => x0.call(x1,x2),
      UB: Function.prototype.call.bind(DataView.prototype.getFloat64),
      UC: o => o instanceof Array,
      UD: x0 => x0.relatedTarget,
      UE: x0 => x0.top,
      UF: x0 => x0.innerHeight,
      UG: x0 => x0.maxWidth,
      UH: x0 => x0.click(),
      UI: x0 => x0.displayHeight,
      UJ: (x0,x1) => x0.createElement(x1),
      UK: (x0,x1) => x0.createObjectStore(x1),
      V: (constructor, args) => {
        const factoryFunction = constructor.bind.apply(
            constructor, [null, ...args]);
        return new factoryFunction();
      },
      VB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float64Array) return 1;
        return 2;
      },
      VC: (a, i) => a[i],
      VD: x0 => x0.hasFocus(),
      VE: x0 => x0.left,
      VF: x0 => x0.innerWidth,
      VG: x0 => x0.minHeight,
      VH: (x0,x1) => x0.getElementsByClassName(x1),
      VI: x0 => x0.displayWidth,
      VJ: x0 => x0.click(),
      VK: x0 => x0.version,
      W: x0 => new Array(x0),
      WB: Function.prototype.call.bind(DataView.prototype.setFloat64),
      WC: a => a.length,
      WD: x0 => x0.shiftKey,
      WE: x0 => x0.scrollTop,
      WF: x0 => x0.height,
      WG: x0 => x0.minWidth,
      WH: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      WI: x0 => x0.duration,
      WJ: x0 => x0.remove(),
      WK: x0 => x0.objectStoreNames,
      X: o => [o],
      XB: (t, s) => t.set(s),
      XC: (x0,x1) => x0.test(x1),
      XD: x0 => x0.body,
      XE: x0 => x0.offsetTop,
      XF: x0 => x0.width,
      XG: Function.prototype.call.bind(DataView.prototype.getBigInt64),
      XH: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF64ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      XI: (x0,x1) => ({frameIndex: x0,completeFramesOnly: x1}),
      XJ: (o, a) => o + a,
      XK: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      Y: (o0, o1) => [o0, o1],
      YB: Function.prototype.call.bind(DataView.prototype.setFloat32),
      YC: x0 => x0.userAgent,
      YD: x0 => x0.visibilityState,
      YE: x0 => x0.scrollLeft,
      YF: x0 => x0.clientHeight,
      YG: Function.prototype.call.bind(DataView.prototype.setBigInt64),
      YH: (x0,x1) => x0.dispatchEvent(x1),
      YI: (x0,x1) => x0.decode(x1),
      YJ: x0 => x0.body,
      YK: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      Z: (o0, o1, o2) => [o0, o1, o2],
      ZB: Function.prototype.call.bind(DataView.prototype.getFloat32),
      ZC: x0 => x0.navigator,
      ZD: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      ZE: x0 => x0.offsetLeft,
      ZF: x0 => x0.clientWidth,
      ZG: (o, start, length) => new BigInt64Array(o.buffer, o.byteOffset + start, length),
      ZH: (x0,x1) => x0.createEvent(x1),
      ZI: x0 => x0.image,
      ZJ: (x0,x1) => { x0.download = x1 },
      ZK: (x0,x1) => { x0.onupgradeneeded = x1 },
      a: (o0, o1, o2, o3) => [o0, o1, o2, o3],
      aB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float32Array) return 1;
        return 2;
      },
      aC: Function.prototype.call.bind(String.prototype.toLowerCase),
      aD: x0 => x0.disconnect(),
      aE: x0 => x0.offsetParent,
      aF: x0 => x0.isConnected,
      aG: (x0,x1,x2,x3) => x0.pushState(x1,x2,x3),
      aH: (x0,x1,x2,x3) => x0.initEvent(x1,x2,x3),
      aI: x0 => x0.close(),
      aJ: (x0,x1) => { x0.display = x1 },
      aK: x0 => x0.indexedDB,
      b: (x0,x1,x2) => { x0[x1] = x2 },
      bB: Function.prototype.call.bind(DataView.prototype.getUint32),
      bC: Object.is,
      bD: x0 => new Intl.Locale(x0),
      bE: x0 => x0.offsetY,
      bF: x0 => x0.head,
      bG: x0 => x0.history,
      bH: x0 => x0.readText(),
      bI: (x0,x1,x2,x3,x4) => ({type: x0,data: x1,premultiplyAlpha: x2,colorSpaceConversion: x3,preferAnimation: x4}),
      bJ: x0 => x0.style,
      bK: x0 => x0.self,
      c: o => o,
      cB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Uint32Array) return 1;
        return 2;
      },
      cC: x0 => x0.vendor,
      cD: x0 => x0.region,
      cE: x0 => x0.offsetX,
      cF: (x0,x1) => { x0.content = x1 },
      cG: x0 => x0.search,
      cH: x0 => x0.clipboard,
      cI: x0 => new window.ImageDecoder(x0),
      cJ: (x0,x1) => { x0.href = x1 },
      cK: () => globalThis.window,
      d: (o, p) => o[p],
      dB: Function.prototype.call.bind(DataView.prototype.getInt32),
      dC: (x0,x1) => x0.createTextNode(x1),
      dD: x0 => x0.script,
      dE: (o, p, r) => o.replace(p, () => r),
      dF: (x0,x1) => { x0.name = x1 },
      dG: x0 => x0.location,
      dH: (x0,x1) => x0.writeText(x1),
      dI: x0 => x0.name,
      dJ: () => globalThis.document,
      dK: (x0,x1,x2,x3,x4,x5,x6,x7,x8,x9) => x0.drawImage(x1,x2,x3,x4,x5,x6,x7,x8,x9),
      e: () => globalThis,
      eB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int32Array) return 1;
        return 2;
      },
      eC: (x0,x1) => { x0.id = x1 },
      eD: x0 => x0.language,
      eE: (x0,x1) => { x0.lastIndex = x1 },
      eF: (x0,x1) => x0.removeChild(x1),
      eG: x0 => x0.pathname,
      eH: x0 => x0.unlock(),
      eI: x0 => x0.repetitionCount,
      eJ: (handle) => clearInterval(handle),
      eK: (x0,x1) => x0.getContext(x1),
      f: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      fB: o => o instanceof Uint16Array,
      fC: (x0,x1) => { x0.nonce = x1 },
      fD: x0 => x0.languages,
      fE: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      fF: x0 => x0.firstChild,
      fG: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      fH: (x0,x1) => x0.lock(x1),
      fI: x0 => x0.frameCount,
      fJ: (ms, c) =>
      setInterval(() => dartInstance.exports.$invokeCallback(c), ms),
      fK: (x0,x1) => { x0.height = x1 },
      g: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      gB: Function.prototype.call.bind(DataView.prototype.getUint16),
      gC: x0 => x0.nonce,
      gD: (x0,x1) => x0.observe(x1),
      gE: o => o instanceof RegExp,
      gF: x0 => x0.viewConstraints,
      gG: o => {
        const proto = Object.getPrototypeOf(o);
        return proto === Object.prototype || proto === null;
      },
      gH: x0 => x0.orientation,
      gI: x0 => x0.selectedTrack,
      gJ: () => Date.now(),
      gK: (x0,x1) => { x0.width = x1 },
      h: (x0,x1) => ({addView: x0,removeView: x1}),
      hB: o => o instanceof Int16Array,
      hC: () => globalThis.window.flutterConfiguration,
      hD: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      hE: x0 => x0.dotAll,
      hF: x0 => x0.hostElement,
      hG: o => Object.keys(o),
      hH: (x0,x1) => x0.querySelector(x1),
      hI: x0 => x0.completed,
      hJ: x0 => x0.debugSkipFontRetryDelay,
      hK: (x0,x1) => x0.transferFromImageBitmap(x1),
      i: (l, r) => l === r,
      iB: Function.prototype.call.bind(DataView.prototype.getInt16),
      iC: (x0,x1) => x0.attachShadow(x1),
      iD: x0 => new ResizeObserver(x0),
      iE: x0 => x0.unicode,
      iF: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      iG: x0 => x0.state,
      iH: (x0,x1) => { x0.title = x1 },
      iI: x0 => x0.ready,
      iJ: x0 => x0.fontFallbackBaseUrl,
      iK: x0 => x0.rasterEndMilliseconds,
      j: x0 => x0.random(),
      jB: o => o instanceof Uint8ClampedArray,
      jC: (x0,x1) => x0.createElement(x1),
      jD: (x0,x1) => x0.getPropertyValue(x1),
      jE: x0 => x0.ignoreCase,
      jF: x0 => ({runApp: x0}),
      jG: x0 => x0.hash,
      jH: (x0,x1) => x0.vibrate(x1),
      jI: x0 => x0.tracks,
      jJ: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      jK: x0 => x0.rasterStartMilliseconds,
      k: o => o,
      kB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Uint8Array) return 1;
        return 2;
      },
      kC: x0 => x0.scale,
      kD: x0 => globalThis.parseFloat(x0),
      kE: x0 => x0.multiline,
      kF: () => typeof dartUseDateNowForTicks !== "undefined",
      kG: x0 => x0.state,
      kH: x0 => x0.arrayBuffer(),
      kI: () => globalThis.window.ImageDecoder,
      kJ: x0 => new MutationObserver(x0),
      kK: x0 => x0.imageBitmaps,
      l: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'number') return 1;
        return 2;
      },
      lB: Function.prototype.call.bind(DataView.prototype.setInt32),
      lC: x0 => x0.visualViewport,
      lD: (x0,x1) => x0.getComputedStyle(x1),
      lE: (o, p, r) => o.replaceAll(p, () => r),
      lF: () => Date.now(),
      lG: (x0,x1) => x0.go(x1),
      lH: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof ArrayBuffer) return 1;
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
          return 2;
        }
        return 3;
      },
      lI: x0 => x0.tee(),
      lJ: (x0,x1,x2,x3) => ({childList: x0,attributes: x1,subtree: x2,attributeFilter: x3}),
      lK: x0 => x0.canvasKitMaximumSurfaces,
      m: () => globalThis.Math,
      mB: Function.prototype.call.bind(DataView.prototype.setUint32),
      mC: x0 => x0.devicePixelRatio,
      mD: x0 => x0.documentElement,
      mE: x0 => x0.deltaMode,
      mF: () => 1000 * performance.now(),
      mG: (x0,x1) => x0.querySelectorAll(x1),
      mH: x0 => x0.status,
      mI: x0 => x0.getReader(),
      mJ: (x0,x1,x2) => x0.observe(x1,x2),
      mK: x0 => x0.hostElement,
      n: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      nB: Function.prototype.call.bind(DataView.prototype.setInt16),
      nC: x0 => x0.height,
      nD: x0 => x0.computedStyleMap(),
      nE: x0 => x0.deltaY,
      nF: (x0,x1) => x0.requestAnimationFrame(x1),
      nG: (x0,x1) => x0.removeProperty(x1),
      nH: (x0,x1) => x0.fetch(x1),
      nI: x0 => x0.length,
      nJ: (x0,x1) => x0.getNamedItem(x1),
      nK: x0 => x0.location,
      o: b => !!b,
      oB: Function.prototype.call.bind(DataView.prototype.setUint16),
      oC: x0 => x0.width,
      oD: (x0,x1) => x0.get(x1),
      oE: x0 => x0.deltaX,
      oF: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      oG: (x0,x1) => x0.add(x1),
      oH: x0 => x0.content,
      oI: x0 => x0.value,
      oJ: (x0,x1,x2) => x0.setAttribute(x1,x2),
      oK: (x0,x1) => x0.getModifierState(x1),
      p: () => globalThis.document,
      pB: Function.prototype.call.bind(DataView.prototype.setUint8),
      pC: x0 => x0.screen,
      pD: (o, p) => p in o,
      pE: x0 => x0.wheelDeltaY,
      pF: x0 => x0.now(),
      pG: x0 => x0.data,
      pH: x0 => x0.document,
      pI: x0 => x0.done,
      pJ: x0 => x0.disconnect(),
      pK: x0 => x0.metaKey,
      q: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      qB: Function.prototype.call.bind(DataView.prototype.setInt8),
      qC: (string, times) => string.repeat(times),
      qD: (x0,x1) => { x0.textContent = x1 },
      qE: x0 => x0.wheelDeltaX,
      qF: x0 => x0.performance,
      qG: (x0,x1) => x0.removeAttribute(x1),
      qH: x0 => new WeakRef(x0),
      qI: x0 => x0.read(),
      qJ: x0 => x0.value,
      qK: x0 => x0.altKey,
      r: (x0,x1) => x0.focus(x1),
      rB: Function.prototype.call.bind(DataView.prototype.getInt8),
      rC: o => {
        if (o === null || o === undefined) return 0;
        if (typeof(o) === 'string') return 1;
        return 2;
      },
      rD: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      rE: x0 => x0.bottom,
      rF: x0 => new Uint8Array(x0),
      rG: (x0,x1) => { x0.value = x1 },
      rH: x0 => x0.deref(),
      rI: x0 => x0.cancel(),
      rJ: x0 => x0.attributes,
      rK: x0 => x0.ctrlKey,
      s: () => ({}),
      sB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int8Array) return 1;
        return 2;
      },
      sC: x0 => x0.tabIndex,
      sD: x0 => x0.matches,
      sE: x0 => x0.right,
      sF: (x0,x1,x2) => x0.slice(x1,x2),
      sG: (x0,x1) => { x0.value = x1 },
      sH: () => globalThis.WeakRef,
      sI: x0 => x0.body,
      sJ: x0 => x0.target,
      sK: x0 => x0.isComposing,
      t: (o, p, v) => o[p] = v,
      tB: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
      tC: (x0,x1) => x0.contains(x1),
      tD: (x0,x1) => x0.matchMedia(x1),
      tE: x0 => x0.clientY,
      tF: (x0,x1) => x0.decode(x1),
      tG: x0 => x0.value,
      tH: (a, i) => a.splice(i, 1),
      tI: (x0,x1) => x0.get(x1),
      tJ: x0 => x0.attributeName,
      tK: x0 => x0.code,
      u: () => [],
      uB: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
      uC: x0 => x0.activeElement,
      uD: x0 => x0.matches,
      uE: x0 => x0.clientX,
      uF: (x0,x1) => x0.adoptText(x1),
      uG: x0 => x0.selectionDirection,
      uH: a => a.pop(),
      uI: x0 => x0.headers,
      uJ: x0 => x0.type,
      uK: x0 => x0.repeat,
      v: (a, i) => a.push(i),
      vB: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
      vC: x0 => x0.parentNode,
      vD: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      vE: x0 => x0.changedTouches,
      vF: x0 => x0.first(),
      vG: x0 => x0.selectionStart,
      vH: (x0,x1,x2) => x0.insertBefore(x1,x2),
      vI: () => {
        // On browsers return `globalThis.location.href`
        if (globalThis.location != null) {
          return globalThis.location.href;
        }
        return null;
      },
      vJ: (x0,x1) => x0.querySelector(x1),
      vK: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      w: x0 => new Int8Array(x0),
      wB: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
      wC: x0 => x0.tagName,
      wD: f => f.dartFunction,
      wE: x0 => x0.key,
      wF: x0 => x0.next(),
      wG: x0 => x0.selectionEnd,
      wH: x0 => x0.id,
      wI: () => {
        return typeof process != "undefined" &&
               Object.prototype.toString.call(process) == "[object process]" &&
               process.platform == "win32"
      },
      wJ: (x0,x1) => x0.querySelector(x1),
      wK: x0 => x0.extraAssets,
      x: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI8ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      xB: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
      xC: x0 => x0.target,
      xD: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      xE: x0 => x0.identifier,
      xF: x0 => x0.current(),
      xG: x0 => x0.value,
      xH: x0 => x0.offsetHeight,
      xI: () => new XMLHttpRequest(),
      xJ: (x0,x1,x2) => x0.open(x1,x2),
      xK: x0 => x0.fontManifest,
      y: x0 => new Uint8Array(x0),
      yB: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
      yC: x0 => x0.clientY,
      yD: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      yE: x0 => x0.touches,
      yF: (x0,x1) => new Intl.v8BreakIterator(x0,x1),
      yG: x0 => x0.selectionDirection,
      yH: x0 => x0.offsetWidth,
      yI: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      yJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      yK: x0 => x0.assetManifest,
      z: x0 => new Uint8ClampedArray(x0),
      zB: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
      zC: x0 => x0.clientX,
      zD: (p, s, f) => p.then(s, (e) => f(e, e === undefined)),
      zE: x0 => x0.pressure,
      zF: x0 => x0.v8BreakIterator,
      zG: x0 => x0.selectionStart,
      zH: x0 => x0.stopPropagation(),
      zI: (x0,x1,x2) => x0.setRequestHeader(x1,x2),
      zJ: (x0,x1) => x0.contains(x1),
      zK: x0 => x0.buildConfig,

    };

    const baseImports = {
      _: dart2wasm,
      Math: Math,
      Date: Date,
      Object: Object,
      Array: Array,
      Reflect: Reflect,
      WebAssembly: {
        JSTag: WebAssembly.JSTag,
      },
      "": new Proxy({}, { get(_, prop) { return prop; } }),

    };

    

    dartInstance = await WebAssembly.instantiate(this.module, {
      ...baseImports,
      ...additionalImports,
      
    });

    return new InstantiatedApp(this, dartInstance);
  }
}

class InstantiatedApp {
  constructor(compiledApp, instantiatedModule) {
    this.compiledApp = compiledApp;
    this.instantiatedModule = instantiatedModule;
  }

  // Call the main function with the given arguments.
  invokeMain(...args) {
    this.instantiatedModule.exports.$invokeMain(args);
  }
}

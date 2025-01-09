// build/dev/javascript/prelude.mjs
var CustomType = class {
  withFields(fields) {
    let properties = Object.keys(this).map(
      (label) => label in fields ? fields[label] : this[label]
    );
    return new this.constructor(...properties);
  }
};
var List = class {
  static fromArray(array3, tail) {
    let t = tail || new Empty();
    for (let i = array3.length - 1; i >= 0; --i) {
      t = new NonEmpty(array3[i], t);
    }
    return t;
  }
  [Symbol.iterator]() {
    return new ListIterator(this);
  }
  toArray() {
    return [...this];
  }
  // @internal
  atLeastLength(desired) {
    for (let _ of this) {
      if (desired <= 0)
        return true;
      desired--;
    }
    return desired <= 0;
  }
  // @internal
  hasLength(desired) {
    for (let _ of this) {
      if (desired <= 0)
        return false;
      desired--;
    }
    return desired === 0;
  }
  // @internal
  countLength() {
    let length4 = 0;
    for (let _ of this)
      length4++;
    return length4;
  }
};
function prepend(element2, tail) {
  return new NonEmpty(element2, tail);
}
function toList(elements2, tail) {
  return List.fromArray(elements2, tail);
}
var ListIterator = class {
  #current;
  constructor(current) {
    this.#current = current;
  }
  next() {
    if (this.#current instanceof Empty) {
      return { done: true };
    } else {
      let { head, tail } = this.#current;
      this.#current = tail;
      return { value: head, done: false };
    }
  }
};
var Empty = class extends List {
};
var NonEmpty = class extends List {
  constructor(head, tail) {
    super();
    this.head = head;
    this.tail = tail;
  }
};
var BitArray = class _BitArray {
  constructor(buffer) {
    if (!(buffer instanceof Uint8Array)) {
      throw "BitArray can only be constructed from a Uint8Array";
    }
    this.buffer = buffer;
  }
  // @internal
  get length() {
    return this.buffer.length;
  }
  // @internal
  byteAt(index3) {
    return this.buffer[index3];
  }
  // @internal
  floatFromSlice(start3, end, isBigEndian) {
    return byteArrayToFloat(this.buffer, start3, end, isBigEndian);
  }
  // @internal
  intFromSlice(start3, end, isBigEndian, isSigned) {
    return byteArrayToInt(this.buffer, start3, end, isBigEndian, isSigned);
  }
  // @internal
  binaryFromSlice(start3, end) {
    const buffer = new Uint8Array(
      this.buffer.buffer,
      this.buffer.byteOffset + start3,
      end - start3
    );
    return new _BitArray(buffer);
  }
  // @internal
  sliceAfter(index3) {
    const buffer = new Uint8Array(
      this.buffer.buffer,
      this.buffer.byteOffset + index3,
      this.buffer.byteLength - index3
    );
    return new _BitArray(buffer);
  }
};
function toBitArray(segments) {
  if (segments.length === 0) {
    return new BitArray(new Uint8Array());
  }
  if (segments.length === 1) {
    if (segments[0] instanceof Uint8Array) {
      return new BitArray(segments[0]);
    }
    return new BitArray(new Uint8Array(segments));
  }
  let bytes = 0;
  let hasUint8ArraySegment = false;
  for (const segment of segments) {
    if (segment instanceof Uint8Array) {
      bytes += segment.byteLength;
      hasUint8ArraySegment = true;
    } else {
      bytes++;
    }
  }
  if (!hasUint8ArraySegment) {
    return new BitArray(new Uint8Array(segments));
  }
  let u8Array = new Uint8Array(bytes);
  let cursor = 0;
  for (let segment of segments) {
    if (segment instanceof Uint8Array) {
      u8Array.set(segment, cursor);
      cursor += segment.byteLength;
    } else {
      u8Array[cursor] = segment;
      cursor++;
    }
  }
  return new BitArray(u8Array);
}
function byteArrayToInt(byteArray, start3, end, isBigEndian, isSigned) {
  const byteSize = end - start3;
  if (byteSize <= 6) {
    let value = 0;
    if (isBigEndian) {
      for (let i = start3; i < end; i++) {
        value = value * 256 + byteArray[i];
      }
    } else {
      for (let i = end - 1; i >= start3; i--) {
        value = value * 256 + byteArray[i];
      }
    }
    if (isSigned) {
      const highBit = 2 ** (byteSize * 8 - 1);
      if (value >= highBit) {
        value -= highBit * 2;
      }
    }
    return value;
  } else {
    let value = 0n;
    if (isBigEndian) {
      for (let i = start3; i < end; i++) {
        value = (value << 8n) + BigInt(byteArray[i]);
      }
    } else {
      for (let i = end - 1; i >= start3; i--) {
        value = (value << 8n) + BigInt(byteArray[i]);
      }
    }
    if (isSigned) {
      const highBit = 1n << BigInt(byteSize * 8 - 1);
      if (value >= highBit) {
        value -= highBit * 2n;
      }
    }
    return Number(value);
  }
}
function byteArrayToFloat(byteArray, start3, end, isBigEndian) {
  const view3 = new DataView(byteArray.buffer);
  const byteSize = end - start3;
  if (byteSize === 8) {
    return view3.getFloat64(start3, !isBigEndian);
  } else if (byteSize === 4) {
    return view3.getFloat32(start3, !isBigEndian);
  } else {
    const msg = `Sized floats must be 32-bit or 64-bit on JavaScript, got size of ${byteSize * 8} bits`;
    throw new globalThis.Error(msg);
  }
}
function stringBits(string3) {
  return new TextEncoder().encode(string3);
}
var Result = class _Result extends CustomType {
  // @internal
  static isResult(data) {
    return data instanceof _Result;
  }
};
var Ok = class extends Result {
  constructor(value) {
    super();
    this[0] = value;
  }
  // @internal
  isOk() {
    return true;
  }
};
var Error = class extends Result {
  constructor(detail) {
    super();
    this[0] = detail;
  }
  // @internal
  isOk() {
    return false;
  }
};
function isEqual(x, y) {
  let values2 = [x, y];
  while (values2.length) {
    let a = values2.pop();
    let b = values2.pop();
    if (a === b)
      continue;
    if (!isObject(a) || !isObject(b))
      return false;
    let unequal = !structurallyCompatibleObjects(a, b) || unequalDates(a, b) || unequalBuffers(a, b) || unequalArrays(a, b) || unequalMaps(a, b) || unequalSets(a, b) || unequalRegExps(a, b);
    if (unequal)
      return false;
    const proto = Object.getPrototypeOf(a);
    if (proto !== null && typeof proto.equals === "function") {
      try {
        if (a.equals(b))
          continue;
        else
          return false;
      } catch {
      }
    }
    let [keys2, get] = getters(a);
    for (let k of keys2(a)) {
      values2.push(get(a, k), get(b, k));
    }
  }
  return true;
}
function getters(object4) {
  if (object4 instanceof Map) {
    return [(x) => x.keys(), (x, y) => x.get(y)];
  } else {
    let extra = object4 instanceof globalThis.Error ? ["message"] : [];
    return [(x) => [...extra, ...Object.keys(x)], (x, y) => x[y]];
  }
}
function unequalDates(a, b) {
  return a instanceof Date && (a > b || a < b);
}
function unequalBuffers(a, b) {
  return a.buffer instanceof ArrayBuffer && a.BYTES_PER_ELEMENT && !(a.byteLength === b.byteLength && a.every((n, i) => n === b[i]));
}
function unequalArrays(a, b) {
  return Array.isArray(a) && a.length !== b.length;
}
function unequalMaps(a, b) {
  return a instanceof Map && a.size !== b.size;
}
function unequalSets(a, b) {
  return a instanceof Set && (a.size != b.size || [...a].some((e) => !b.has(e)));
}
function unequalRegExps(a, b) {
  return a instanceof RegExp && (a.source !== b.source || a.flags !== b.flags);
}
function isObject(a) {
  return typeof a === "object" && a !== null;
}
function structurallyCompatibleObjects(a, b) {
  if (typeof a !== "object" && typeof b !== "object" && (!a || !b))
    return false;
  let nonstructural = [Promise, WeakSet, WeakMap, Function];
  if (nonstructural.some((c) => a instanceof c))
    return false;
  return a.constructor === b.constructor;
}
function remainderInt(a, b) {
  if (b === 0) {
    return 0;
  } else {
    return a % b;
  }
}
function makeError(variant, module, line, fn, message, extra) {
  let error2 = new globalThis.Error(message);
  error2.gleam_error = variant;
  error2.module = module;
  error2.line = line;
  error2.function = fn;
  error2.fn = fn;
  for (let k in extra)
    error2[k] = extra[k];
  return error2;
}

// build/dev/javascript/gleam_stdlib/gleam/option.mjs
var Some = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var None = class extends CustomType {
};
function to_result(option, e) {
  if (option instanceof Some) {
    let a = option[0];
    return new Ok(a);
  } else {
    return new Error(e);
  }
}
function unwrap(option, default$) {
  if (option instanceof Some) {
    let x = option[0];
    return x;
  } else {
    return default$;
  }
}

// build/dev/javascript/gleam_stdlib/dict.mjs
var referenceMap = /* @__PURE__ */ new WeakMap();
var tempDataView = new DataView(new ArrayBuffer(8));
var referenceUID = 0;
function hashByReference(o) {
  const known = referenceMap.get(o);
  if (known !== void 0) {
    return known;
  }
  const hash = referenceUID++;
  if (referenceUID === 2147483647) {
    referenceUID = 0;
  }
  referenceMap.set(o, hash);
  return hash;
}
function hashMerge(a, b) {
  return a ^ b + 2654435769 + (a << 6) + (a >> 2) | 0;
}
function hashString(s) {
  let hash = 0;
  const len = s.length;
  for (let i = 0; i < len; i++) {
    hash = Math.imul(31, hash) + s.charCodeAt(i) | 0;
  }
  return hash;
}
function hashNumber(n) {
  tempDataView.setFloat64(0, n);
  const i = tempDataView.getInt32(0);
  const j = tempDataView.getInt32(4);
  return Math.imul(73244475, i >> 16 ^ i) ^ j;
}
function hashBigInt(n) {
  return hashString(n.toString());
}
function hashObject(o) {
  const proto = Object.getPrototypeOf(o);
  if (proto !== null && typeof proto.hashCode === "function") {
    try {
      const code = o.hashCode(o);
      if (typeof code === "number") {
        return code;
      }
    } catch {
    }
  }
  if (o instanceof Promise || o instanceof WeakSet || o instanceof WeakMap) {
    return hashByReference(o);
  }
  if (o instanceof Date) {
    return hashNumber(o.getTime());
  }
  let h = 0;
  if (o instanceof ArrayBuffer) {
    o = new Uint8Array(o);
  }
  if (Array.isArray(o) || o instanceof Uint8Array) {
    for (let i = 0; i < o.length; i++) {
      h = Math.imul(31, h) + getHash(o[i]) | 0;
    }
  } else if (o instanceof Set) {
    o.forEach((v) => {
      h = h + getHash(v) | 0;
    });
  } else if (o instanceof Map) {
    o.forEach((v, k) => {
      h = h + hashMerge(getHash(v), getHash(k)) | 0;
    });
  } else {
    const keys2 = Object.keys(o);
    for (let i = 0; i < keys2.length; i++) {
      const k = keys2[i];
      const v = o[k];
      h = h + hashMerge(getHash(v), hashString(k)) | 0;
    }
  }
  return h;
}
function getHash(u) {
  if (u === null)
    return 1108378658;
  if (u === void 0)
    return 1108378659;
  if (u === true)
    return 1108378657;
  if (u === false)
    return 1108378656;
  switch (typeof u) {
    case "number":
      return hashNumber(u);
    case "string":
      return hashString(u);
    case "bigint":
      return hashBigInt(u);
    case "object":
      return hashObject(u);
    case "symbol":
      return hashByReference(u);
    case "function":
      return hashByReference(u);
    default:
      return 0;
  }
}
var SHIFT = 5;
var BUCKET_SIZE = Math.pow(2, SHIFT);
var MASK = BUCKET_SIZE - 1;
var MAX_INDEX_NODE = BUCKET_SIZE / 2;
var MIN_ARRAY_NODE = BUCKET_SIZE / 4;
var ENTRY = 0;
var ARRAY_NODE = 1;
var INDEX_NODE = 2;
var COLLISION_NODE = 3;
var EMPTY = {
  type: INDEX_NODE,
  bitmap: 0,
  array: []
};
function mask(hash, shift) {
  return hash >>> shift & MASK;
}
function bitpos(hash, shift) {
  return 1 << mask(hash, shift);
}
function bitcount(x) {
  x -= x >> 1 & 1431655765;
  x = (x & 858993459) + (x >> 2 & 858993459);
  x = x + (x >> 4) & 252645135;
  x += x >> 8;
  x += x >> 16;
  return x & 127;
}
function index(bitmap, bit) {
  return bitcount(bitmap & bit - 1);
}
function cloneAndSet(arr, at, val) {
  const len = arr.length;
  const out = new Array(len);
  for (let i = 0; i < len; ++i) {
    out[i] = arr[i];
  }
  out[at] = val;
  return out;
}
function spliceIn(arr, at, val) {
  const len = arr.length;
  const out = new Array(len + 1);
  let i = 0;
  let g = 0;
  while (i < at) {
    out[g++] = arr[i++];
  }
  out[g++] = val;
  while (i < len) {
    out[g++] = arr[i++];
  }
  return out;
}
function spliceOut(arr, at) {
  const len = arr.length;
  const out = new Array(len - 1);
  let i = 0;
  let g = 0;
  while (i < at) {
    out[g++] = arr[i++];
  }
  ++i;
  while (i < len) {
    out[g++] = arr[i++];
  }
  return out;
}
function createNode(shift, key1, val1, key2hash, key2, val2) {
  const key1hash = getHash(key1);
  if (key1hash === key2hash) {
    return {
      type: COLLISION_NODE,
      hash: key1hash,
      array: [
        { type: ENTRY, k: key1, v: val1 },
        { type: ENTRY, k: key2, v: val2 }
      ]
    };
  }
  const addedLeaf = { val: false };
  return assoc(
    assocIndex(EMPTY, shift, key1hash, key1, val1, addedLeaf),
    shift,
    key2hash,
    key2,
    val2,
    addedLeaf
  );
}
function assoc(root, shift, hash, key, val, addedLeaf) {
  switch (root.type) {
    case ARRAY_NODE:
      return assocArray(root, shift, hash, key, val, addedLeaf);
    case INDEX_NODE:
      return assocIndex(root, shift, hash, key, val, addedLeaf);
    case COLLISION_NODE:
      return assocCollision(root, shift, hash, key, val, addedLeaf);
  }
}
function assocArray(root, shift, hash, key, val, addedLeaf) {
  const idx = mask(hash, shift);
  const node = root.array[idx];
  if (node === void 0) {
    addedLeaf.val = true;
    return {
      type: ARRAY_NODE,
      size: root.size + 1,
      array: cloneAndSet(root.array, idx, { type: ENTRY, k: key, v: val })
    };
  }
  if (node.type === ENTRY) {
    if (isEqual(key, node.k)) {
      if (val === node.v) {
        return root;
      }
      return {
        type: ARRAY_NODE,
        size: root.size,
        array: cloneAndSet(root.array, idx, {
          type: ENTRY,
          k: key,
          v: val
        })
      };
    }
    addedLeaf.val = true;
    return {
      type: ARRAY_NODE,
      size: root.size,
      array: cloneAndSet(
        root.array,
        idx,
        createNode(shift + SHIFT, node.k, node.v, hash, key, val)
      )
    };
  }
  const n = assoc(node, shift + SHIFT, hash, key, val, addedLeaf);
  if (n === node) {
    return root;
  }
  return {
    type: ARRAY_NODE,
    size: root.size,
    array: cloneAndSet(root.array, idx, n)
  };
}
function assocIndex(root, shift, hash, key, val, addedLeaf) {
  const bit = bitpos(hash, shift);
  const idx = index(root.bitmap, bit);
  if ((root.bitmap & bit) !== 0) {
    const node = root.array[idx];
    if (node.type !== ENTRY) {
      const n = assoc(node, shift + SHIFT, hash, key, val, addedLeaf);
      if (n === node) {
        return root;
      }
      return {
        type: INDEX_NODE,
        bitmap: root.bitmap,
        array: cloneAndSet(root.array, idx, n)
      };
    }
    const nodeKey = node.k;
    if (isEqual(key, nodeKey)) {
      if (val === node.v) {
        return root;
      }
      return {
        type: INDEX_NODE,
        bitmap: root.bitmap,
        array: cloneAndSet(root.array, idx, {
          type: ENTRY,
          k: key,
          v: val
        })
      };
    }
    addedLeaf.val = true;
    return {
      type: INDEX_NODE,
      bitmap: root.bitmap,
      array: cloneAndSet(
        root.array,
        idx,
        createNode(shift + SHIFT, nodeKey, node.v, hash, key, val)
      )
    };
  } else {
    const n = root.array.length;
    if (n >= MAX_INDEX_NODE) {
      const nodes = new Array(32);
      const jdx = mask(hash, shift);
      nodes[jdx] = assocIndex(EMPTY, shift + SHIFT, hash, key, val, addedLeaf);
      let j = 0;
      let bitmap = root.bitmap;
      for (let i = 0; i < 32; i++) {
        if ((bitmap & 1) !== 0) {
          const node = root.array[j++];
          nodes[i] = node;
        }
        bitmap = bitmap >>> 1;
      }
      return {
        type: ARRAY_NODE,
        size: n + 1,
        array: nodes
      };
    } else {
      const newArray = spliceIn(root.array, idx, {
        type: ENTRY,
        k: key,
        v: val
      });
      addedLeaf.val = true;
      return {
        type: INDEX_NODE,
        bitmap: root.bitmap | bit,
        array: newArray
      };
    }
  }
}
function assocCollision(root, shift, hash, key, val, addedLeaf) {
  if (hash === root.hash) {
    const idx = collisionIndexOf(root, key);
    if (idx !== -1) {
      const entry = root.array[idx];
      if (entry.v === val) {
        return root;
      }
      return {
        type: COLLISION_NODE,
        hash,
        array: cloneAndSet(root.array, idx, { type: ENTRY, k: key, v: val })
      };
    }
    const size = root.array.length;
    addedLeaf.val = true;
    return {
      type: COLLISION_NODE,
      hash,
      array: cloneAndSet(root.array, size, { type: ENTRY, k: key, v: val })
    };
  }
  return assoc(
    {
      type: INDEX_NODE,
      bitmap: bitpos(root.hash, shift),
      array: [root]
    },
    shift,
    hash,
    key,
    val,
    addedLeaf
  );
}
function collisionIndexOf(root, key) {
  const size = root.array.length;
  for (let i = 0; i < size; i++) {
    if (isEqual(key, root.array[i].k)) {
      return i;
    }
  }
  return -1;
}
function find(root, shift, hash, key) {
  switch (root.type) {
    case ARRAY_NODE:
      return findArray(root, shift, hash, key);
    case INDEX_NODE:
      return findIndex(root, shift, hash, key);
    case COLLISION_NODE:
      return findCollision(root, key);
  }
}
function findArray(root, shift, hash, key) {
  const idx = mask(hash, shift);
  const node = root.array[idx];
  if (node === void 0) {
    return void 0;
  }
  if (node.type !== ENTRY) {
    return find(node, shift + SHIFT, hash, key);
  }
  if (isEqual(key, node.k)) {
    return node;
  }
  return void 0;
}
function findIndex(root, shift, hash, key) {
  const bit = bitpos(hash, shift);
  if ((root.bitmap & bit) === 0) {
    return void 0;
  }
  const idx = index(root.bitmap, bit);
  const node = root.array[idx];
  if (node.type !== ENTRY) {
    return find(node, shift + SHIFT, hash, key);
  }
  if (isEqual(key, node.k)) {
    return node;
  }
  return void 0;
}
function findCollision(root, key) {
  const idx = collisionIndexOf(root, key);
  if (idx < 0) {
    return void 0;
  }
  return root.array[idx];
}
function without(root, shift, hash, key) {
  switch (root.type) {
    case ARRAY_NODE:
      return withoutArray(root, shift, hash, key);
    case INDEX_NODE:
      return withoutIndex(root, shift, hash, key);
    case COLLISION_NODE:
      return withoutCollision(root, key);
  }
}
function withoutArray(root, shift, hash, key) {
  const idx = mask(hash, shift);
  const node = root.array[idx];
  if (node === void 0) {
    return root;
  }
  let n = void 0;
  if (node.type === ENTRY) {
    if (!isEqual(node.k, key)) {
      return root;
    }
  } else {
    n = without(node, shift + SHIFT, hash, key);
    if (n === node) {
      return root;
    }
  }
  if (n === void 0) {
    if (root.size <= MIN_ARRAY_NODE) {
      const arr = root.array;
      const out = new Array(root.size - 1);
      let i = 0;
      let j = 0;
      let bitmap = 0;
      while (i < idx) {
        const nv = arr[i];
        if (nv !== void 0) {
          out[j] = nv;
          bitmap |= 1 << i;
          ++j;
        }
        ++i;
      }
      ++i;
      while (i < arr.length) {
        const nv = arr[i];
        if (nv !== void 0) {
          out[j] = nv;
          bitmap |= 1 << i;
          ++j;
        }
        ++i;
      }
      return {
        type: INDEX_NODE,
        bitmap,
        array: out
      };
    }
    return {
      type: ARRAY_NODE,
      size: root.size - 1,
      array: cloneAndSet(root.array, idx, n)
    };
  }
  return {
    type: ARRAY_NODE,
    size: root.size,
    array: cloneAndSet(root.array, idx, n)
  };
}
function withoutIndex(root, shift, hash, key) {
  const bit = bitpos(hash, shift);
  if ((root.bitmap & bit) === 0) {
    return root;
  }
  const idx = index(root.bitmap, bit);
  const node = root.array[idx];
  if (node.type !== ENTRY) {
    const n = without(node, shift + SHIFT, hash, key);
    if (n === node) {
      return root;
    }
    if (n !== void 0) {
      return {
        type: INDEX_NODE,
        bitmap: root.bitmap,
        array: cloneAndSet(root.array, idx, n)
      };
    }
    if (root.bitmap === bit) {
      return void 0;
    }
    return {
      type: INDEX_NODE,
      bitmap: root.bitmap ^ bit,
      array: spliceOut(root.array, idx)
    };
  }
  if (isEqual(key, node.k)) {
    if (root.bitmap === bit) {
      return void 0;
    }
    return {
      type: INDEX_NODE,
      bitmap: root.bitmap ^ bit,
      array: spliceOut(root.array, idx)
    };
  }
  return root;
}
function withoutCollision(root, key) {
  const idx = collisionIndexOf(root, key);
  if (idx < 0) {
    return root;
  }
  if (root.array.length === 1) {
    return void 0;
  }
  return {
    type: COLLISION_NODE,
    hash: root.hash,
    array: spliceOut(root.array, idx)
  };
}
function forEach(root, fn) {
  if (root === void 0) {
    return;
  }
  const items = root.array;
  const size = items.length;
  for (let i = 0; i < size; i++) {
    const item = items[i];
    if (item === void 0) {
      continue;
    }
    if (item.type === ENTRY) {
      fn(item.v, item.k);
      continue;
    }
    forEach(item, fn);
  }
}
var Dict = class _Dict {
  /**
   * @template V
   * @param {Record<string,V>} o
   * @returns {Dict<string,V>}
   */
  static fromObject(o) {
    const keys2 = Object.keys(o);
    let m = _Dict.new();
    for (let i = 0; i < keys2.length; i++) {
      const k = keys2[i];
      m = m.set(k, o[k]);
    }
    return m;
  }
  /**
   * @template K,V
   * @param {Map<K,V>} o
   * @returns {Dict<K,V>}
   */
  static fromMap(o) {
    let m = _Dict.new();
    o.forEach((v, k) => {
      m = m.set(k, v);
    });
    return m;
  }
  static new() {
    return new _Dict(void 0, 0);
  }
  /**
   * @param {undefined | Node<K,V>} root
   * @param {number} size
   */
  constructor(root, size) {
    this.root = root;
    this.size = size;
  }
  /**
   * @template NotFound
   * @param {K} key
   * @param {NotFound} notFound
   * @returns {NotFound | V}
   */
  get(key, notFound) {
    if (this.root === void 0) {
      return notFound;
    }
    const found = find(this.root, 0, getHash(key), key);
    if (found === void 0) {
      return notFound;
    }
    return found.v;
  }
  /**
   * @param {K} key
   * @param {V} val
   * @returns {Dict<K,V>}
   */
  set(key, val) {
    const addedLeaf = { val: false };
    const root = this.root === void 0 ? EMPTY : this.root;
    const newRoot = assoc(root, 0, getHash(key), key, val, addedLeaf);
    if (newRoot === this.root) {
      return this;
    }
    return new _Dict(newRoot, addedLeaf.val ? this.size + 1 : this.size);
  }
  /**
   * @param {K} key
   * @returns {Dict<K,V>}
   */
  delete(key) {
    if (this.root === void 0) {
      return this;
    }
    const newRoot = without(this.root, 0, getHash(key), key);
    if (newRoot === this.root) {
      return this;
    }
    if (newRoot === void 0) {
      return _Dict.new();
    }
    return new _Dict(newRoot, this.size - 1);
  }
  /**
   * @param {K} key
   * @returns {boolean}
   */
  has(key) {
    if (this.root === void 0) {
      return false;
    }
    return find(this.root, 0, getHash(key), key) !== void 0;
  }
  /**
   * @returns {[K,V][]}
   */
  entries() {
    if (this.root === void 0) {
      return [];
    }
    const result = [];
    this.forEach((v, k) => result.push([k, v]));
    return result;
  }
  /**
   *
   * @param {(val:V,key:K)=>void} fn
   */
  forEach(fn) {
    forEach(this.root, fn);
  }
  hashCode() {
    let h = 0;
    this.forEach((v, k) => {
      h = h + hashMerge(getHash(v), getHash(k)) | 0;
    });
    return h;
  }
  /**
   * @param {unknown} o
   * @returns {boolean}
   */
  equals(o) {
    if (!(o instanceof _Dict) || this.size !== o.size) {
      return false;
    }
    try {
      this.forEach((v, k) => {
        if (!isEqual(o.get(k, !v), v)) {
          throw unequalDictSymbol;
        }
      });
      return true;
    } catch (e) {
      if (e === unequalDictSymbol) {
        return false;
      }
      throw e;
    }
  }
};
var unequalDictSymbol = Symbol();

// build/dev/javascript/gleam_stdlib/gleam_stdlib.mjs
var Nil = void 0;
var NOT_FOUND = {};
function identity(x) {
  return x;
}
function to_string(term) {
  return term.toString();
}
function float_to_string(float3) {
  const string3 = float3.toString().replace("+", "");
  if (string3.indexOf(".") >= 0) {
    return string3;
  } else {
    const index3 = string3.indexOf("e");
    if (index3 >= 0) {
      return string3.slice(0, index3) + ".0" + string3.slice(index3);
    } else {
      return string3 + ".0";
    }
  }
}
function string_replace(string3, target, substitute) {
  if (typeof string3.replaceAll !== "undefined") {
    return string3.replaceAll(target, substitute);
  }
  return string3.replace(
    // $& means the whole matched string
    new RegExp(target.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"), "g"),
    substitute
  );
}
var segmenter = void 0;
function graphemes_iterator(string3) {
  if (globalThis.Intl && Intl.Segmenter) {
    segmenter ||= new Intl.Segmenter();
    return segmenter.segment(string3)[Symbol.iterator]();
  }
}
function pop_grapheme(string3) {
  let first2;
  const iterator = graphemes_iterator(string3);
  if (iterator) {
    first2 = iterator.next().value?.segment;
  } else {
    first2 = string3.match(/./su)?.[0];
  }
  if (first2) {
    return new Ok([first2, string3.slice(first2.length)]);
  } else {
    return new Error(Nil);
  }
}
function pop_codeunit(str) {
  return [str.charCodeAt(0) | 0, str.slice(1)];
}
function lowercase(string3) {
  return string3.toLowerCase();
}
function add(a, b) {
  return a + b;
}
function join(xs, separator) {
  const iterator = xs[Symbol.iterator]();
  let result = iterator.next().value || "";
  let current = iterator.next();
  while (!current.done) {
    result = result + separator + current.value;
    current = iterator.next();
  }
  return result;
}
function concat(xs) {
  let result = "";
  for (const x of xs) {
    result = result + x;
  }
  return result;
}
function length(data) {
  return data.length;
}
function string_codeunit_slice(str, from2, length4) {
  return str.slice(from2, from2 + length4);
}
function starts_with(haystack, needle) {
  return haystack.startsWith(needle);
}
var unicode_whitespaces = [
  " ",
  // Space
  "	",
  // Horizontal tab
  "\n",
  // Line feed
  "\v",
  // Vertical tab
  "\f",
  // Form feed
  "\r",
  // Carriage return
  "\x85",
  // Next line
  "\u2028",
  // Line separator
  "\u2029"
  // Paragraph separator
].join("");
var trim_start_regex = new RegExp(`^[${unicode_whitespaces}]*`);
var trim_end_regex = new RegExp(`[${unicode_whitespaces}]*$`);
function bit_array_from_string(string3) {
  return toBitArray([stringBits(string3)]);
}
function new_map() {
  return Dict.new();
}
function map_to_list(map7) {
  return List.fromArray(map7.entries());
}
function map_get(map7, key) {
  const value = map7.get(key, NOT_FOUND);
  if (value === NOT_FOUND) {
    return new Error(Nil);
  }
  return new Ok(value);
}
function map_insert(key, value, map7) {
  return map7.set(key, value);
}
function percent_encode(string3) {
  return encodeURIComponent(string3).replace("%2B", "+");
}
var b64EncodeLookup = [
  65,
  66,
  67,
  68,
  69,
  70,
  71,
  72,
  73,
  74,
  75,
  76,
  77,
  78,
  79,
  80,
  81,
  82,
  83,
  84,
  85,
  86,
  87,
  88,
  89,
  90,
  97,
  98,
  99,
  100,
  101,
  102,
  103,
  104,
  105,
  106,
  107,
  108,
  109,
  110,
  111,
  112,
  113,
  114,
  115,
  116,
  117,
  118,
  119,
  120,
  121,
  122,
  48,
  49,
  50,
  51,
  52,
  53,
  54,
  55,
  56,
  57,
  43,
  47
];
var b64TextDecoder;
function encode64(bit_array2, padding) {
  b64TextDecoder ??= new TextDecoder();
  const bytes = bit_array2.buffer;
  const m = bytes.length;
  const k = m % 3;
  const n = Math.floor(m / 3) * 4 + (k && k + 1);
  const N = Math.ceil(m / 3) * 4;
  const encoded = new Uint8Array(N);
  for (let i = 0, j = 0; j < m; i += 4, j += 3) {
    const y = (bytes[j] << 16) + (bytes[j + 1] << 8) + (bytes[j + 2] | 0);
    encoded[i] = b64EncodeLookup[y >> 18];
    encoded[i + 1] = b64EncodeLookup[y >> 12 & 63];
    encoded[i + 2] = b64EncodeLookup[y >> 6 & 63];
    encoded[i + 3] = b64EncodeLookup[y & 63];
  }
  let base64 = b64TextDecoder.decode(new Uint8Array(encoded.buffer, 0, n));
  if (padding) {
    if (k === 1) {
      base64 += "==";
    } else if (k === 2) {
      base64 += "=";
    }
  }
  return base64;
}
function decode64(sBase64) {
  try {
    const binString = atob(sBase64);
    const length4 = binString.length;
    const array3 = new Uint8Array(length4);
    for (let i = 0; i < length4; i++) {
      array3[i] = binString.charCodeAt(i);
    }
    return new Ok(new BitArray(array3));
  } catch {
    return new Error(Nil);
  }
}
function classify_dynamic(data) {
  if (typeof data === "string") {
    return "String";
  } else if (typeof data === "boolean") {
    return "Bool";
  } else if (data instanceof Result) {
    return "Result";
  } else if (data instanceof List) {
    return "List";
  } else if (data instanceof BitArray) {
    return "BitArray";
  } else if (data instanceof Dict) {
    return "Dict";
  } else if (Number.isInteger(data)) {
    return "Int";
  } else if (Array.isArray(data)) {
    return `Tuple of ${data.length} elements`;
  } else if (typeof data === "number") {
    return "Float";
  } else if (data === null) {
    return "Null";
  } else if (data === void 0) {
    return "Nil";
  } else {
    const type = typeof data;
    return type.charAt(0).toUpperCase() + type.slice(1);
  }
}
function decoder_error(expected, got) {
  return decoder_error_no_classify(expected, classify_dynamic(got));
}
function decoder_error_no_classify(expected, got) {
  return new Error(
    List.fromArray([new DecodeError(expected, got, List.fromArray([]))])
  );
}
function decode_string(data) {
  return typeof data === "string" ? new Ok(data) : decoder_error("String", data);
}
function decode_int(data) {
  return Number.isInteger(data) ? new Ok(data) : decoder_error("Int", data);
}
function decode_float(data) {
  return typeof data === "number" ? new Ok(data) : decoder_error("Float", data);
}
function decode_bool(data) {
  return typeof data === "boolean" ? new Ok(data) : decoder_error("Bool", data);
}
function decode_list(data) {
  if (Array.isArray(data)) {
    return new Ok(List.fromArray(data));
  }
  return data instanceof List ? new Ok(data) : decoder_error("List", data);
}
function decode_option(data, decoder) {
  if (data === null || data === void 0 || data instanceof None)
    return new Ok(new None());
  if (data instanceof Some)
    data = data[0];
  const result = decoder(data);
  if (result.isOk()) {
    return new Ok(new Some(result[0]));
  } else {
    return result;
  }
}
function decode_field(value, name) {
  const not_a_map_error = () => decoder_error("Dict", value);
  if (value instanceof Dict || value instanceof WeakMap || value instanceof Map) {
    const entry = map_get(value, name);
    return new Ok(entry.isOk() ? new Some(entry[0]) : new None());
  } else if (value === null) {
    return not_a_map_error();
  } else if (Object.getPrototypeOf(value) == Object.prototype) {
    return try_get_field(value, name, () => new Ok(new None()));
  } else {
    return try_get_field(value, name, not_a_map_error);
  }
}
function try_get_field(value, field3, or_else) {
  try {
    return field3 in value ? new Ok(new Some(value[field3])) : or_else();
  } catch {
    return or_else();
  }
}

// build/dev/javascript/gleam_stdlib/gleam/dict.mjs
function insert(dict2, key, value) {
  return map_insert(key, value, dict2);
}
function from_list_loop(loop$list, loop$initial) {
  while (true) {
    let list4 = loop$list;
    let initial = loop$initial;
    if (list4.hasLength(0)) {
      return initial;
    } else {
      let x = list4.head;
      let rest = list4.tail;
      loop$list = rest;
      loop$initial = insert(initial, x[0], x[1]);
    }
  }
}
function from_list(list4) {
  return from_list_loop(list4, new_map());
}
function reverse_and_concat(loop$remaining, loop$accumulator) {
  while (true) {
    let remaining = loop$remaining;
    let accumulator = loop$accumulator;
    if (remaining.hasLength(0)) {
      return accumulator;
    } else {
      let item = remaining.head;
      let rest = remaining.tail;
      loop$remaining = rest;
      loop$accumulator = prepend(item, accumulator);
    }
  }
}
function do_keys_loop(loop$list, loop$acc) {
  while (true) {
    let list4 = loop$list;
    let acc = loop$acc;
    if (list4.hasLength(0)) {
      return reverse_and_concat(acc, toList([]));
    } else {
      let first2 = list4.head;
      let rest = list4.tail;
      loop$list = rest;
      loop$acc = prepend(first2[0], acc);
    }
  }
}
function keys(dict2) {
  let list_of_pairs = map_to_list(dict2);
  return do_keys_loop(list_of_pairs, toList([]));
}

// build/dev/javascript/gleam_stdlib/gleam/list.mjs
function reverse_loop(loop$remaining, loop$accumulator) {
  while (true) {
    let remaining = loop$remaining;
    let accumulator = loop$accumulator;
    if (remaining.hasLength(0)) {
      return accumulator;
    } else {
      let item = remaining.head;
      let rest$1 = remaining.tail;
      loop$remaining = rest$1;
      loop$accumulator = prepend(item, accumulator);
    }
  }
}
function reverse(list4) {
  return reverse_loop(list4, toList([]));
}
function map_loop(loop$list, loop$fun, loop$acc) {
  while (true) {
    let list4 = loop$list;
    let fun = loop$fun;
    let acc = loop$acc;
    if (list4.hasLength(0)) {
      return reverse(acc);
    } else {
      let first$1 = list4.head;
      let rest$1 = list4.tail;
      loop$list = rest$1;
      loop$fun = fun;
      loop$acc = prepend(fun(first$1), acc);
    }
  }
}
function map(list4, fun) {
  return map_loop(list4, fun, toList([]));
}
function try_map_loop(loop$list, loop$fun, loop$acc) {
  while (true) {
    let list4 = loop$list;
    let fun = loop$fun;
    let acc = loop$acc;
    if (list4.hasLength(0)) {
      return new Ok(reverse(acc));
    } else {
      let first$1 = list4.head;
      let rest$1 = list4.tail;
      let $ = fun(first$1);
      if ($.isOk()) {
        let first$2 = $[0];
        loop$list = rest$1;
        loop$fun = fun;
        loop$acc = prepend(first$2, acc);
      } else {
        let error2 = $[0];
        return new Error(error2);
      }
    }
  }
}
function try_map(list4, fun) {
  return try_map_loop(list4, fun, toList([]));
}
function append_loop(loop$first, loop$second) {
  while (true) {
    let first2 = loop$first;
    let second = loop$second;
    if (first2.hasLength(0)) {
      return second;
    } else {
      let item = first2.head;
      let rest$1 = first2.tail;
      loop$first = rest$1;
      loop$second = prepend(item, second);
    }
  }
}
function append(first2, second) {
  return append_loop(reverse(first2), second);
}
function reverse_and_prepend(loop$prefix, loop$suffix) {
  while (true) {
    let prefix = loop$prefix;
    let suffix = loop$suffix;
    if (prefix.hasLength(0)) {
      return suffix;
    } else {
      let first$1 = prefix.head;
      let rest$1 = prefix.tail;
      loop$prefix = rest$1;
      loop$suffix = prepend(first$1, suffix);
    }
  }
}
function flatten_loop(loop$lists, loop$acc) {
  while (true) {
    let lists = loop$lists;
    let acc = loop$acc;
    if (lists.hasLength(0)) {
      return reverse(acc);
    } else {
      let list4 = lists.head;
      let further_lists = lists.tail;
      loop$lists = further_lists;
      loop$acc = reverse_and_prepend(list4, acc);
    }
  }
}
function flatten(lists) {
  return flatten_loop(lists, toList([]));
}
function flat_map(list4, fun) {
  let _pipe = map(list4, fun);
  return flatten(_pipe);
}
function fold(loop$list, loop$initial, loop$fun) {
  while (true) {
    let list4 = loop$list;
    let initial = loop$initial;
    let fun = loop$fun;
    if (list4.hasLength(0)) {
      return initial;
    } else {
      let x = list4.head;
      let rest$1 = list4.tail;
      loop$list = rest$1;
      loop$initial = fun(initial, x);
      loop$fun = fun;
    }
  }
}
function index_fold_loop(loop$over, loop$acc, loop$with, loop$index) {
  while (true) {
    let over = loop$over;
    let acc = loop$acc;
    let with$ = loop$with;
    let index3 = loop$index;
    if (over.hasLength(0)) {
      return acc;
    } else {
      let first$1 = over.head;
      let rest$1 = over.tail;
      loop$over = rest$1;
      loop$acc = with$(acc, first$1, index3);
      loop$with = with$;
      loop$index = index3 + 1;
    }
  }
}
function index_fold(list4, initial, fun) {
  return index_fold_loop(list4, initial, fun, 0);
}
function find_map(loop$list, loop$fun) {
  while (true) {
    let list4 = loop$list;
    let fun = loop$fun;
    if (list4.hasLength(0)) {
      return new Error(void 0);
    } else {
      let x = list4.head;
      let rest$1 = list4.tail;
      let $ = fun(x);
      if ($.isOk()) {
        let x$1 = $[0];
        return new Ok(x$1);
      } else {
        loop$list = rest$1;
        loop$fun = fun;
      }
    }
  }
}
function intersperse_loop(loop$list, loop$separator, loop$acc) {
  while (true) {
    let list4 = loop$list;
    let separator = loop$separator;
    let acc = loop$acc;
    if (list4.hasLength(0)) {
      return reverse(acc);
    } else {
      let x = list4.head;
      let rest$1 = list4.tail;
      loop$list = rest$1;
      loop$separator = separator;
      loop$acc = prepend(x, prepend(separator, acc));
    }
  }
}
function intersperse(list4, elem) {
  if (list4.hasLength(0)) {
    return list4;
  } else if (list4.hasLength(1)) {
    return list4;
  } else {
    let x = list4.head;
    let rest$1 = list4.tail;
    return intersperse_loop(rest$1, elem, toList([x]));
  }
}
function key_find(keyword_list, desired_key) {
  return find_map(
    keyword_list,
    (keyword) => {
      let key = keyword[0];
      let value = keyword[1];
      let $ = isEqual(key, desired_key);
      if ($) {
        return new Ok(value);
      } else {
        return new Error(void 0);
      }
    }
  );
}

// build/dev/javascript/gleam_stdlib/gleam/string_tree.mjs
function append2(tree, second) {
  return add(tree, identity(second));
}

// build/dev/javascript/gleam_stdlib/gleam/string.mjs
function replace(string3, pattern, substitute) {
  let _pipe = string3;
  let _pipe$1 = identity(_pipe);
  let _pipe$2 = string_replace(_pipe$1, pattern, substitute);
  return identity(_pipe$2);
}
function append3(first2, second) {
  let _pipe = first2;
  let _pipe$1 = identity(_pipe);
  let _pipe$2 = append2(_pipe$1, second);
  return identity(_pipe$2);
}
function concat2(strings) {
  let _pipe = strings;
  let _pipe$1 = concat(_pipe);
  return identity(_pipe$1);
}
function repeat_loop(loop$string, loop$times, loop$acc) {
  while (true) {
    let string3 = loop$string;
    let times = loop$times;
    let acc = loop$acc;
    let $ = times <= 0;
    if ($) {
      return acc;
    } else {
      loop$string = string3;
      loop$times = times - 1;
      loop$acc = acc + string3;
    }
  }
}
function repeat(string3, times) {
  return repeat_loop(string3, times, "");
}
function drop_start(loop$string, loop$num_graphemes) {
  while (true) {
    let string3 = loop$string;
    let num_graphemes = loop$num_graphemes;
    let $ = num_graphemes > 0;
    if (!$) {
      return string3;
    } else {
      let $1 = pop_grapheme(string3);
      if ($1.isOk()) {
        let string$1 = $1[0][1];
        loop$string = string$1;
        loop$num_graphemes = num_graphemes - 1;
      } else {
        return string3;
      }
    }
  }
}

// build/dev/javascript/gleam_stdlib/gleam/bit_array.mjs
function base64_decode(encoded) {
  let padded = (() => {
    let $ = remainderInt(length(bit_array_from_string(encoded)), 4);
    if ($ === 0) {
      return encoded;
    } else {
      let n = $;
      return append3(encoded, repeat("=", 4 - n));
    }
  })();
  return decode64(padded);
}
function base64_url_encode(input, padding) {
  let _pipe = encode64(input, padding);
  let _pipe$1 = replace(_pipe, "+", "-");
  return replace(_pipe$1, "/", "_");
}
function base64_url_decode(encoded) {
  let _pipe = encoded;
  let _pipe$1 = replace(_pipe, "-", "+");
  let _pipe$2 = replace(_pipe$1, "_", "/");
  return base64_decode(_pipe$2);
}

// build/dev/javascript/gleam_stdlib/gleam/result.mjs
function map2(result, fun) {
  if (result.isOk()) {
    let x = result[0];
    return new Ok(fun(x));
  } else {
    let e = result[0];
    return new Error(e);
  }
}
function map_error(result, fun) {
  if (result.isOk()) {
    let x = result[0];
    return new Ok(x);
  } else {
    let error2 = result[0];
    return new Error(fun(error2));
  }
}
function try$(result, fun) {
  if (result.isOk()) {
    let x = result[0];
    return fun(x);
  } else {
    let e = result[0];
    return new Error(e);
  }
}
function then$(result, fun) {
  return try$(result, fun);
}
function partition_loop(loop$results, loop$oks, loop$errors) {
  while (true) {
    let results = loop$results;
    let oks = loop$oks;
    let errors = loop$errors;
    if (results.hasLength(0)) {
      return [oks, errors];
    } else if (results.atLeastLength(1) && results.head.isOk()) {
      let a = results.head[0];
      let rest = results.tail;
      loop$results = rest;
      loop$oks = prepend(a, oks);
      loop$errors = errors;
    } else {
      let e = results.head[0];
      let rest = results.tail;
      loop$results = rest;
      loop$oks = oks;
      loop$errors = prepend(e, errors);
    }
  }
}
function partition(results) {
  return partition_loop(results, toList([]), toList([]));
}
function replace_error(result, error2) {
  if (result.isOk()) {
    let x = result[0];
    return new Ok(x);
  } else {
    return new Error(error2);
  }
}

// build/dev/javascript/gleam_stdlib/gleam/dynamic.mjs
var DecodeError = class extends CustomType {
  constructor(expected, found, path) {
    super();
    this.expected = expected;
    this.found = found;
    this.path = path;
  }
};
function dynamic(value) {
  return new Ok(value);
}
function int(data) {
  return decode_int(data);
}
function float(data) {
  return decode_float(data);
}
function bool(data) {
  return decode_bool(data);
}
function shallow_list(value) {
  return decode_list(value);
}
function optional(decode3) {
  return (value) => {
    return decode_option(value, decode3);
  };
}
function any(decoders) {
  return (data) => {
    if (decoders.hasLength(0)) {
      return new Error(
        toList([new DecodeError("another type", classify_dynamic(data), toList([]))])
      );
    } else {
      let decoder = decoders.head;
      let decoders$1 = decoders.tail;
      let $ = decoder(data);
      if ($.isOk()) {
        let decoded = $[0];
        return new Ok(decoded);
      } else {
        return any(decoders$1)(data);
      }
    }
  };
}
function push_path(error2, name) {
  let name$1 = identity(name);
  let decoder = any(
    toList([decode_string, (x) => {
      return map2(int(x), to_string);
    }])
  );
  let name$2 = (() => {
    let $ = decoder(name$1);
    if ($.isOk()) {
      let name$22 = $[0];
      return name$22;
    } else {
      let _pipe = toList(["<", classify_dynamic(name$1), ">"]);
      let _pipe$1 = concat(_pipe);
      return identity(_pipe$1);
    }
  })();
  let _record = error2;
  return new DecodeError(
    _record.expected,
    _record.found,
    prepend(name$2, error2.path)
  );
}
function list(decoder_type) {
  return (dynamic2) => {
    return try$(
      shallow_list(dynamic2),
      (list4) => {
        let _pipe = list4;
        let _pipe$1 = try_map(_pipe, decoder_type);
        return map_errors(
          _pipe$1,
          (_capture) => {
            return push_path(_capture, "*");
          }
        );
      }
    );
  };
}
function map_errors(result, f) {
  return map_error(
    result,
    (_capture) => {
      return map(_capture, f);
    }
  );
}
function field(name, inner_type) {
  return (value) => {
    let missing_field_error = new DecodeError("field", "nothing", toList([]));
    return try$(
      decode_field(value, name),
      (maybe_inner) => {
        let _pipe = maybe_inner;
        let _pipe$1 = to_result(_pipe, toList([missing_field_error]));
        let _pipe$2 = try$(_pipe$1, inner_type);
        return map_errors(
          _pipe$2,
          (_capture) => {
            return push_path(_capture, name);
          }
        );
      }
    );
  };
}

// build/dev/javascript/gleam_stdlib/gleam/bool.mjs
function to_string2(bool4) {
  if (!bool4) {
    return "False";
  } else {
    return "True";
  }
}
function guard(requirement, consequence, alternative) {
  if (requirement) {
    return consequence;
  } else {
    return alternative();
  }
}

// build/dev/javascript/gleam_json/gleam_json_ffi.mjs
function json_to_string(json) {
  return JSON.stringify(json);
}
function object(entries) {
  return Object.fromEntries(entries);
}
function identity2(x) {
  return x;
}
function array(list4) {
  return list4.toArray();
}
function do_null() {
  return null;
}

// build/dev/javascript/gleam_json/gleam/json.mjs
var UnexpectedFormat = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
function to_string3(json) {
  return json_to_string(json);
}
function string(input) {
  return identity2(input);
}
function bool2(input) {
  return identity2(input);
}
function int2(input) {
  return identity2(input);
}
function float2(input) {
  return identity2(input);
}
function null$() {
  return do_null();
}
function nullable(input, inner_type) {
  if (input instanceof Some) {
    let value = input[0];
    return inner_type(value);
  } else {
    return null$();
  }
}
function object2(entries) {
  return object(entries);
}
function preprocessed_array(from2) {
  return array(from2);
}
function array2(entries, inner_type) {
  let _pipe = entries;
  let _pipe$1 = map(_pipe, inner_type);
  return preprocessed_array(_pipe$1);
}

// build/dev/javascript/lustre/lustre/effect.mjs
var Effect = class extends CustomType {
  constructor(all) {
    super();
    this.all = all;
  }
};
function custom(run2) {
  return new Effect(
    toList([
      (actions) => {
        return run2(actions.dispatch, actions.emit, actions.select, actions.root);
      }
    ])
  );
}
function from(effect) {
  return custom((dispatch, _, _1, _2) => {
    return effect(dispatch);
  });
}
function none() {
  return new Effect(toList([]));
}

// build/dev/javascript/lustre/lustre/internals/vdom.mjs
var Text = class extends CustomType {
  constructor(content) {
    super();
    this.content = content;
  }
};
var Element = class extends CustomType {
  constructor(key, namespace, tag, attrs, children2, self_closing, void$) {
    super();
    this.key = key;
    this.namespace = namespace;
    this.tag = tag;
    this.attrs = attrs;
    this.children = children2;
    this.self_closing = self_closing;
    this.void = void$;
  }
};
var Map2 = class extends CustomType {
  constructor(subtree) {
    super();
    this.subtree = subtree;
  }
};
var Attribute = class extends CustomType {
  constructor(x0, x1, as_property) {
    super();
    this[0] = x0;
    this[1] = x1;
    this.as_property = as_property;
  }
};
var Event = class extends CustomType {
  constructor(x0, x1) {
    super();
    this[0] = x0;
    this[1] = x1;
  }
};
function attribute_to_event_handler(attribute2) {
  if (attribute2 instanceof Attribute) {
    return new Error(void 0);
  } else {
    let name = attribute2[0];
    let handler = attribute2[1];
    let name$1 = drop_start(name, 2);
    return new Ok([name$1, handler]);
  }
}
function do_element_list_handlers(elements2, handlers2, key) {
  return index_fold(
    elements2,
    handlers2,
    (handlers3, element2, index3) => {
      let key$1 = key + "-" + to_string(index3);
      return do_handlers(element2, handlers3, key$1);
    }
  );
}
function do_handlers(loop$element, loop$handlers, loop$key) {
  while (true) {
    let element2 = loop$element;
    let handlers2 = loop$handlers;
    let key = loop$key;
    if (element2 instanceof Text) {
      return handlers2;
    } else if (element2 instanceof Map2) {
      let subtree = element2.subtree;
      loop$element = subtree();
      loop$handlers = handlers2;
      loop$key = key;
    } else {
      let attrs = element2.attrs;
      let children2 = element2.children;
      let handlers$1 = fold(
        attrs,
        handlers2,
        (handlers3, attr) => {
          let $ = attribute_to_event_handler(attr);
          if ($.isOk()) {
            let name = $[0][0];
            let handler = $[0][1];
            return insert(handlers3, key + "-" + name, handler);
          } else {
            return handlers3;
          }
        }
      );
      return do_element_list_handlers(children2, handlers$1, key);
    }
  }
}
function handlers(element2) {
  return do_handlers(element2, new_map(), "0");
}

// build/dev/javascript/lustre/lustre/attribute.mjs
function on(name, handler) {
  return new Event("on" + name, handler);
}

// build/dev/javascript/lustre/lustre/element.mjs
function element(tag, attrs, children2) {
  if (tag === "area") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "base") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "br") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "col") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "embed") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "hr") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "img") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "input") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "link") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "meta") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "param") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "source") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "track") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "wbr") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else {
    return new Element("", "", tag, attrs, children2, false, false);
  }
}
function text(content) {
  return new Text(content);
}

// build/dev/javascript/gleam_stdlib/gleam/set.mjs
var Set2 = class extends CustomType {
  constructor(dict2) {
    super();
    this.dict = dict2;
  }
};
function new$2() {
  return new Set2(new_map());
}

// build/dev/javascript/lustre/lustre/internals/patch.mjs
var Diff = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var Emit = class extends CustomType {
  constructor(x0, x1) {
    super();
    this[0] = x0;
    this[1] = x1;
  }
};
var Init = class extends CustomType {
  constructor(x0, x1) {
    super();
    this[0] = x0;
    this[1] = x1;
  }
};
function is_empty_element_diff(diff2) {
  return isEqual(diff2.created, new_map()) && isEqual(
    diff2.removed,
    new$2()
  ) && isEqual(diff2.updated, new_map());
}

// build/dev/javascript/lustre/lustre/internals/runtime.mjs
var Attrs = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var Batch = class extends CustomType {
  constructor(x0, x1) {
    super();
    this[0] = x0;
    this[1] = x1;
  }
};
var Debug = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var Dispatch = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var Emit2 = class extends CustomType {
  constructor(x0, x1) {
    super();
    this[0] = x0;
    this[1] = x1;
  }
};
var Event2 = class extends CustomType {
  constructor(x0, x1) {
    super();
    this[0] = x0;
    this[1] = x1;
  }
};
var Shutdown = class extends CustomType {
};
var Subscribe = class extends CustomType {
  constructor(x0, x1) {
    super();
    this[0] = x0;
    this[1] = x1;
  }
};
var Unsubscribe = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var ForceModel = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};

// build/dev/javascript/lustre/vdom.ffi.mjs
if (globalThis.customElements && !globalThis.customElements.get("lustre-fragment")) {
  globalThis.customElements.define(
    "lustre-fragment",
    class LustreFragment extends HTMLElement {
      constructor() {
        super();
      }
    }
  );
}
function morph(prev, next, dispatch) {
  let out;
  let stack = [{ prev, next, parent: prev.parentNode }];
  while (stack.length) {
    let { prev: prev2, next: next2, parent } = stack.pop();
    while (next2.subtree !== void 0)
      next2 = next2.subtree();
    if (next2.content !== void 0) {
      if (!prev2) {
        const created = document.createTextNode(next2.content);
        parent.appendChild(created);
        out ??= created;
      } else if (prev2.nodeType === Node.TEXT_NODE) {
        if (prev2.textContent !== next2.content)
          prev2.textContent = next2.content;
        out ??= prev2;
      } else {
        const created = document.createTextNode(next2.content);
        parent.replaceChild(created, prev2);
        out ??= created;
      }
    } else if (next2.tag !== void 0) {
      const created = createElementNode({
        prev: prev2,
        next: next2,
        dispatch,
        stack
      });
      if (!prev2) {
        parent.appendChild(created);
      } else if (prev2 !== created) {
        parent.replaceChild(created, prev2);
      }
      out ??= created;
    }
  }
  return out;
}
function createElementNode({ prev, next, dispatch, stack }) {
  const namespace = next.namespace || "http://www.w3.org/1999/xhtml";
  const canMorph = prev && prev.nodeType === Node.ELEMENT_NODE && prev.localName === next.tag && prev.namespaceURI === (next.namespace || "http://www.w3.org/1999/xhtml");
  const el = canMorph ? prev : namespace ? document.createElementNS(namespace, next.tag) : document.createElement(next.tag);
  let handlersForEl;
  if (!registeredHandlers.has(el)) {
    const emptyHandlers = /* @__PURE__ */ new Map();
    registeredHandlers.set(el, emptyHandlers);
    handlersForEl = emptyHandlers;
  } else {
    handlersForEl = registeredHandlers.get(el);
  }
  const prevHandlers = canMorph ? new Set(handlersForEl.keys()) : null;
  const prevAttributes = canMorph ? new Set(Array.from(prev.attributes, (a) => a.name)) : null;
  let className = null;
  let style2 = null;
  let innerHTML = null;
  if (canMorph && next.tag === "textarea") {
    const innertText = next.children[Symbol.iterator]().next().value?.content;
    if (innertText !== void 0)
      el.value = innertText;
  }
  const delegated = [];
  for (const attr of next.attrs) {
    const name = attr[0];
    const value = attr[1];
    if (attr.as_property) {
      if (el[name] !== value)
        el[name] = value;
      if (canMorph)
        prevAttributes.delete(name);
    } else if (name.startsWith("on")) {
      const eventName = name.slice(2);
      const callback = dispatch(value, eventName === "input");
      if (!handlersForEl.has(eventName)) {
        el.addEventListener(eventName, lustreGenericEventHandler);
      }
      handlersForEl.set(eventName, callback);
      if (canMorph)
        prevHandlers.delete(eventName);
    } else if (name.startsWith("data-lustre-on-")) {
      const eventName = name.slice(15);
      const callback = dispatch(lustreServerEventHandler);
      if (!handlersForEl.has(eventName)) {
        el.addEventListener(eventName, lustreGenericEventHandler);
      }
      handlersForEl.set(eventName, callback);
      el.setAttribute(name, value);
      if (canMorph) {
        prevHandlers.delete(eventName);
        prevAttributes.delete(name);
      }
    } else if (name.startsWith("delegate:data-") || name.startsWith("delegate:aria-")) {
      el.setAttribute(name, value);
      delegated.push([name.slice(10), value]);
    } else if (name === "class") {
      className = className === null ? value : className + " " + value;
    } else if (name === "style") {
      style2 = style2 === null ? value : style2 + value;
    } else if (name === "dangerous-unescaped-html") {
      innerHTML = value;
    } else {
      if (el.getAttribute(name) !== value)
        el.setAttribute(name, value);
      if (name === "value" || name === "selected")
        el[name] = value;
      if (canMorph)
        prevAttributes.delete(name);
    }
  }
  if (className !== null) {
    el.setAttribute("class", className);
    if (canMorph)
      prevAttributes.delete("class");
  }
  if (style2 !== null) {
    el.setAttribute("style", style2);
    if (canMorph)
      prevAttributes.delete("style");
  }
  if (canMorph) {
    for (const attr of prevAttributes) {
      el.removeAttribute(attr);
    }
    for (const eventName of prevHandlers) {
      handlersForEl.delete(eventName);
      el.removeEventListener(eventName, lustreGenericEventHandler);
    }
  }
  if (next.tag === "slot") {
    window.queueMicrotask(() => {
      for (const child of el.assignedElements()) {
        for (const [name, value] of delegated) {
          if (!child.hasAttribute(name)) {
            child.setAttribute(name, value);
          }
        }
      }
    });
  }
  if (next.key !== void 0 && next.key !== "") {
    el.setAttribute("data-lustre-key", next.key);
  } else if (innerHTML !== null) {
    el.innerHTML = innerHTML;
    return el;
  }
  let prevChild = el.firstChild;
  let seenKeys = null;
  let keyedChildren = null;
  let incomingKeyedChildren = null;
  let firstChild = children(next).next().value;
  if (canMorph && firstChild !== void 0 && // Explicit checks are more verbose but truthy checks force a bunch of comparisons
  // we don't care about: it's never gonna be a number etc.
  firstChild.key !== void 0 && firstChild.key !== "") {
    seenKeys = /* @__PURE__ */ new Set();
    keyedChildren = getKeyedChildren(prev);
    incomingKeyedChildren = getKeyedChildren(next);
    for (const child of children(next)) {
      prevChild = diffKeyedChild(
        prevChild,
        child,
        el,
        stack,
        incomingKeyedChildren,
        keyedChildren,
        seenKeys
      );
    }
  } else {
    for (const child of children(next)) {
      stack.unshift({ prev: prevChild, next: child, parent: el });
      prevChild = prevChild?.nextSibling;
    }
  }
  while (prevChild) {
    const next2 = prevChild.nextSibling;
    el.removeChild(prevChild);
    prevChild = next2;
  }
  return el;
}
var registeredHandlers = /* @__PURE__ */ new WeakMap();
function lustreGenericEventHandler(event2) {
  const target = event2.currentTarget;
  if (!registeredHandlers.has(target)) {
    target.removeEventListener(event2.type, lustreGenericEventHandler);
    return;
  }
  const handlersForEventTarget = registeredHandlers.get(target);
  if (!handlersForEventTarget.has(event2.type)) {
    target.removeEventListener(event2.type, lustreGenericEventHandler);
    return;
  }
  handlersForEventTarget.get(event2.type)(event2);
}
function lustreServerEventHandler(event2) {
  const el = event2.currentTarget;
  const tag = el.getAttribute(`data-lustre-on-${event2.type}`);
  const data = JSON.parse(el.getAttribute("data-lustre-data") || "{}");
  const include = JSON.parse(el.getAttribute("data-lustre-include") || "[]");
  switch (event2.type) {
    case "input":
    case "change":
      include.push("target.value");
      break;
  }
  return {
    tag,
    data: include.reduce(
      (data2, property) => {
        const path = property.split(".");
        for (let i = 0, o = data2, e = event2; i < path.length; i++) {
          if (i === path.length - 1) {
            o[path[i]] = e[path[i]];
          } else {
            o[path[i]] ??= {};
            e = e[path[i]];
            o = o[path[i]];
          }
        }
        return data2;
      },
      { data }
    )
  };
}
function getKeyedChildren(el) {
  const keyedChildren = /* @__PURE__ */ new Map();
  if (el) {
    for (const child of children(el)) {
      const key = child?.key || child?.getAttribute?.("data-lustre-key");
      if (key)
        keyedChildren.set(key, child);
    }
  }
  return keyedChildren;
}
function diffKeyedChild(prevChild, child, el, stack, incomingKeyedChildren, keyedChildren, seenKeys) {
  while (prevChild && !incomingKeyedChildren.has(prevChild.getAttribute("data-lustre-key"))) {
    const nextChild = prevChild.nextSibling;
    el.removeChild(prevChild);
    prevChild = nextChild;
  }
  if (keyedChildren.size === 0) {
    stack.unshift({ prev: prevChild, next: child, parent: el });
    prevChild = prevChild?.nextSibling;
    return prevChild;
  }
  if (seenKeys.has(child.key)) {
    console.warn(`Duplicate key found in Lustre vnode: ${child.key}`);
    stack.unshift({ prev: null, next: child, parent: el });
    return prevChild;
  }
  seenKeys.add(child.key);
  const keyedChild = keyedChildren.get(child.key);
  if (!keyedChild && !prevChild) {
    stack.unshift({ prev: null, next: child, parent: el });
    return prevChild;
  }
  if (!keyedChild && prevChild !== null) {
    const placeholder = document.createTextNode("");
    el.insertBefore(placeholder, prevChild);
    stack.unshift({ prev: placeholder, next: child, parent: el });
    return prevChild;
  }
  if (!keyedChild || keyedChild === prevChild) {
    stack.unshift({ prev: prevChild, next: child, parent: el });
    prevChild = prevChild?.nextSibling;
    return prevChild;
  }
  el.insertBefore(keyedChild, prevChild);
  stack.unshift({ prev: keyedChild, next: child, parent: el });
  return prevChild;
}
function* children(element2) {
  for (const child of element2.children) {
    yield* forceChild(child);
  }
}
function* forceChild(element2) {
  if (element2.subtree !== void 0) {
    yield* forceChild(element2.subtree());
  } else {
    yield element2;
  }
}

// build/dev/javascript/lustre/lustre.ffi.mjs
var LustreClientApplication = class _LustreClientApplication {
  /**
   * @template Flags
   *
   * @param {object} app
   * @param {(flags: Flags) => [Model, Lustre.Effect<Msg>]} app.init
   * @param {(msg: Msg, model: Model) => [Model, Lustre.Effect<Msg>]} app.update
   * @param {(model: Model) => Lustre.Element<Msg>} app.view
   * @param {string | HTMLElement} selector
   * @param {Flags} flags
   *
   * @returns {Gleam.Ok<(action: Lustre.Action<Lustre.Client, Msg>>) => void>}
   */
  static start({ init: init3, update: update2, view: view3 }, selector, flags) {
    if (!is_browser())
      return new Error(new NotABrowser());
    const root = selector instanceof HTMLElement ? selector : document.querySelector(selector);
    if (!root)
      return new Error(new ElementNotFound(selector));
    const app = new _LustreClientApplication(root, init3(flags), update2, view3);
    return new Ok((action) => app.send(action));
  }
  /**
   * @param {Element} root
   * @param {[Model, Lustre.Effect<Msg>]} init
   * @param {(model: Model, msg: Msg) => [Model, Lustre.Effect<Msg>]} update
   * @param {(model: Model) => Lustre.Element<Msg>} view
   *
   * @returns {LustreClientApplication}
   */
  constructor(root, [init3, effects], update2, view3) {
    this.root = root;
    this.#model = init3;
    this.#update = update2;
    this.#view = view3;
    this.#tickScheduled = window.requestAnimationFrame(
      () => this.#tick(effects.all.toArray(), true)
    );
  }
  /** @type {Element} */
  root;
  /**
   * @param {Lustre.Action<Lustre.Client, Msg>} action
   *
   * @returns {void}
   */
  send(action) {
    if (action instanceof Debug) {
      if (action[0] instanceof ForceModel) {
        this.#tickScheduled = window.cancelAnimationFrame(this.#tickScheduled);
        this.#queue = [];
        this.#model = action[0][0];
        const vdom = this.#view(this.#model);
        const dispatch = (handler, immediate = false) => (event2) => {
          const result = handler(event2);
          if (result instanceof Ok) {
            this.send(new Dispatch(result[0], immediate));
          }
        };
        const prev = this.root.firstChild ?? this.root.appendChild(document.createTextNode(""));
        morph(prev, vdom, dispatch);
      }
    } else if (action instanceof Dispatch) {
      const msg = action[0];
      const immediate = action[1] ?? false;
      this.#queue.push(msg);
      if (immediate) {
        this.#tickScheduled = window.cancelAnimationFrame(this.#tickScheduled);
        this.#tick();
      } else if (!this.#tickScheduled) {
        this.#tickScheduled = window.requestAnimationFrame(() => this.#tick());
      }
    } else if (action instanceof Emit2) {
      const event2 = action[0];
      const data = action[1];
      this.root.dispatchEvent(
        new CustomEvent(event2, {
          detail: data,
          bubbles: true,
          composed: true
        })
      );
    } else if (action instanceof Shutdown) {
      this.#tickScheduled = window.cancelAnimationFrame(this.#tickScheduled);
      this.#model = null;
      this.#update = null;
      this.#view = null;
      this.#queue = null;
      while (this.root.firstChild) {
        this.root.firstChild.remove();
      }
    }
  }
  /** @type {Model} */
  #model;
  /** @type {(model: Model, msg: Msg) => [Model, Lustre.Effect<Msg>]} */
  #update;
  /** @type {(model: Model) => Lustre.Element<Msg>} */
  #view;
  /** @type {Array<Msg>} */
  #queue = [];
  /** @type {number | undefined} */
  #tickScheduled;
  /**
   * @param {Lustre.Effect<Msg>[]} effects
   */
  #tick(effects = []) {
    this.#tickScheduled = void 0;
    this.#flush(effects);
    const vdom = this.#view(this.#model);
    const dispatch = (handler, immediate = false) => (event2) => {
      const result = handler(event2);
      if (result instanceof Ok) {
        this.send(new Dispatch(result[0], immediate));
      }
    };
    const prev = this.root.firstChild ?? this.root.appendChild(document.createTextNode(""));
    morph(prev, vdom, dispatch);
  }
  #flush(effects = []) {
    while (this.#queue.length > 0) {
      const msg = this.#queue.shift();
      const [next, effect] = this.#update(this.#model, msg);
      effects = effects.concat(effect.all.toArray());
      this.#model = next;
    }
    while (effects.length > 0) {
      const effect = effects.shift();
      const dispatch = (msg) => this.send(new Dispatch(msg));
      const emit2 = (event2, data) => this.root.dispatchEvent(
        new CustomEvent(event2, {
          detail: data,
          bubbles: true,
          composed: true
        })
      );
      const select = () => {
      };
      const root = this.root;
      effect({ dispatch, emit: emit2, select, root });
    }
    if (this.#queue.length > 0) {
      this.#flush(effects);
    }
  }
};
var start = LustreClientApplication.start;
var LustreServerApplication = class _LustreServerApplication {
  static start({ init: init3, update: update2, view: view3, on_attribute_change }, flags) {
    const app = new _LustreServerApplication(
      init3(flags),
      update2,
      view3,
      on_attribute_change
    );
    return new Ok((action) => app.send(action));
  }
  constructor([model, effects], update2, view3, on_attribute_change) {
    this.#model = model;
    this.#update = update2;
    this.#view = view3;
    this.#html = view3(model);
    this.#onAttributeChange = on_attribute_change;
    this.#renderers = /* @__PURE__ */ new Map();
    this.#handlers = handlers(this.#html);
    this.#tick(effects.all.toArray());
  }
  send(action) {
    if (action instanceof Attrs) {
      for (const attr of action[0]) {
        const decoder = this.#onAttributeChange.get(attr[0]);
        if (!decoder)
          continue;
        const msg = decoder(attr[1]);
        if (msg instanceof Error)
          continue;
        this.#queue.push(msg);
      }
      this.#tick();
    } else if (action instanceof Batch) {
      this.#queue = this.#queue.concat(action[0].toArray());
      this.#tick(action[1].all.toArray());
    } else if (action instanceof Debug) {
    } else if (action instanceof Dispatch) {
      this.#queue.push(action[0]);
      this.#tick();
    } else if (action instanceof Emit2) {
      const event2 = new Emit(action[0], action[1]);
      for (const [_, renderer] of this.#renderers) {
        renderer(event2);
      }
    } else if (action instanceof Event2) {
      const handler = this.#handlers.get(action[0]);
      if (!handler)
        return;
      const msg = handler(action[1]);
      if (msg instanceof Error)
        return;
      this.#queue.push(msg[0]);
      this.#tick();
    } else if (action instanceof Subscribe) {
      const attrs = keys(this.#onAttributeChange);
      const patch = new Init(attrs, this.#html);
      this.#renderers = this.#renderers.set(action[0], action[1]);
      action[1](patch);
    } else if (action instanceof Unsubscribe) {
      this.#renderers = this.#renderers.delete(action[0]);
    }
  }
  #model;
  #update;
  #queue;
  #view;
  #html;
  #renderers;
  #handlers;
  #onAttributeChange;
  #tick(effects = []) {
    this.#flush(effects);
    const vdom = this.#view(this.#model);
    const diff2 = elements(this.#html, vdom);
    if (!is_empty_element_diff(diff2)) {
      const patch = new Diff(diff2);
      for (const [_, renderer] of this.#renderers) {
        renderer(patch);
      }
    }
    this.#html = vdom;
    this.#handlers = diff2.handlers;
  }
  #flush(effects = []) {
    while (this.#queue.length > 0) {
      const msg = this.#queue.shift();
      const [next, effect] = this.#update(this.#model, msg);
      effects = effects.concat(effect.all.toArray());
      this.#model = next;
    }
    while (effects.length > 0) {
      const effect = effects.shift();
      const dispatch = (msg) => this.send(new Dispatch(msg));
      const emit2 = (event2, data) => this.root.dispatchEvent(
        new CustomEvent(event2, {
          detail: data,
          bubbles: true,
          composed: true
        })
      );
      const select = () => {
      };
      const root = null;
      effect({ dispatch, emit: emit2, select, root });
    }
    if (this.#queue.length > 0) {
      this.#flush(effects);
    }
  }
};
var start_server_application = LustreServerApplication.start;
var is_browser = () => globalThis.window && window.document;

// build/dev/javascript/lustre/lustre.mjs
var App = class extends CustomType {
  constructor(init3, update2, view3, on_attribute_change) {
    super();
    this.init = init3;
    this.update = update2;
    this.view = view3;
    this.on_attribute_change = on_attribute_change;
  }
};
var ElementNotFound = class extends CustomType {
  constructor(selector) {
    super();
    this.selector = selector;
  }
};
var NotABrowser = class extends CustomType {
};
function application(init3, update2, view3) {
  return new App(init3, update2, view3, new None());
}
function start2(app, selector, flags) {
  return guard(
    !is_browser(),
    new Error(new NotABrowser()),
    () => {
      return start(app, selector, flags);
    }
  );
}

// build/dev/javascript/convert/convert.mjs
var String2 = class extends CustomType {
};
var Bool = class extends CustomType {
};
var Float = class extends CustomType {
};
var Int = class extends CustomType {
};
var Null = class extends CustomType {
};
var List2 = class extends CustomType {
  constructor(of) {
    super();
    this.of = of;
  }
};
var Dict2 = class extends CustomType {
  constructor(key, value) {
    super();
    this.key = key;
    this.value = value;
  }
};
var Object2 = class extends CustomType {
  constructor(fields) {
    super();
    this.fields = fields;
  }
};
var Optional = class extends CustomType {
  constructor(of) {
    super();
    this.of = of;
  }
};
var Result2 = class extends CustomType {
  constructor(result, error2) {
    super();
    this.result = result;
    this.error = error2;
  }
};
var Enum = class extends CustomType {
  constructor(variants) {
    super();
    this.variants = variants;
  }
};
var BitArray2 = class extends CustomType {
};
var StringValue = class extends CustomType {
  constructor(value) {
    super();
    this.value = value;
  }
};
var BoolValue = class extends CustomType {
  constructor(value) {
    super();
    this.value = value;
  }
};
var FloatValue = class extends CustomType {
  constructor(value) {
    super();
    this.value = value;
  }
};
var IntValue = class extends CustomType {
  constructor(value) {
    super();
    this.value = value;
  }
};
var NullValue = class extends CustomType {
};
var ListValue = class extends CustomType {
  constructor(value) {
    super();
    this.value = value;
  }
};
var DictValue = class extends CustomType {
  constructor(value) {
    super();
    this.value = value;
  }
};
var ObjectValue = class extends CustomType {
  constructor(value) {
    super();
    this.value = value;
  }
};
var OptionalValue = class extends CustomType {
  constructor(value) {
    super();
    this.value = value;
  }
};
var ResultValue = class extends CustomType {
  constructor(value) {
    super();
    this.value = value;
  }
};
var EnumValue = class extends CustomType {
  constructor(variant, value) {
    super();
    this.variant = variant;
    this.value = value;
  }
};
var DynamicValue = class extends CustomType {
  constructor(value) {
    super();
    this.value = value;
  }
};
var BitArrayValue = class extends CustomType {
  constructor(value) {
    super();
    this.value = value;
  }
};
var Converter = class extends CustomType {
  constructor(encoder, decoder, type_def2, default_value) {
    super();
    this.encoder = encoder;
    this.decoder = decoder;
    this.type_def = type_def2;
    this.default_value = default_value;
  }
};
var PartialConverter = class extends CustomType {
  constructor(encoder, decoder, fields_def, default_value) {
    super();
    this.encoder = encoder;
    this.decoder = decoder;
    this.fields_def = fields_def;
    this.default_value = default_value;
  }
};
function object3(converter) {
  let $ = converter.default_value;
  if (!$.isOk()) {
    throw makeError(
      "let_assert",
      "convert",
      84,
      "object",
      "Pattern match failed, no pattern matched the value.",
      { value: $ }
    );
  }
  let default_value = $[0];
  return new Converter(
    converter.encoder,
    converter.decoder,
    new Object2(converter.fields_def),
    default_value
  );
}
function success(c) {
  return new PartialConverter(
    (_) => {
      return new ObjectValue(toList([]));
    },
    (_) => {
      return new Ok(c);
    },
    toList([]),
    new Ok(c)
  );
}
function get_type(val) {
  if (val instanceof BoolValue) {
    return "BoolValue";
  } else if (val instanceof DictValue) {
    return "DictValue";
  } else if (val instanceof EnumValue) {
    return "EnumValue";
  } else if (val instanceof FloatValue) {
    return "FloatValue";
  } else if (val instanceof IntValue) {
    return "IntValue";
  } else if (val instanceof ListValue) {
    return "ListValue";
  } else if (val instanceof NullValue) {
    return "NullValue";
  } else if (val instanceof ObjectValue) {
    return "ObjectValue";
  } else if (val instanceof OptionalValue) {
    return "OptionalValue";
  } else if (val instanceof ResultValue) {
    return "ResultValue";
  } else if (val instanceof StringValue) {
    return "StringValue";
  } else if (val instanceof DynamicValue) {
    return "DynamicValue";
  } else {
    return "BitArrayValue";
  }
}
function string2() {
  return new Converter(
    (v) => {
      return new StringValue(v);
    },
    (v) => {
      if (v instanceof StringValue) {
        let val = v.value;
        return new Ok(val);
      } else {
        let other = v;
        return new Error(
          toList([
            new DecodeError("StringValue", get_type(other), toList([]))
          ])
        );
      }
    },
    new String2(),
    ""
  );
}
function null$2() {
  return new Converter(
    (_) => {
      return new NullValue();
    },
    (v) => {
      if (v instanceof NullValue) {
        return new Ok(void 0);
      } else {
        let other = v;
        return new Error(
          toList([
            new DecodeError("NullValue", get_type(other), toList([]))
          ])
        );
      }
    },
    new Null(),
    void 0
  );
}
function field2(field_name, field_getter, field_type, next) {
  return new PartialConverter(
    (base) => {
      let value = field_getter(base);
      if (!value.isOk() && !value[0]) {
        return new NullValue();
      } else {
        let field_value = value[0];
        let converter = next(field_value);
        let $ = converter.encoder(base);
        if ($ instanceof ObjectValue) {
          let fields = $.value;
          return new ObjectValue(
            prepend([field_name, field_type.encoder(field_value)], fields)
          );
        } else {
          return new NullValue();
        }
      }
    },
    (v) => {
      if (v instanceof ObjectValue) {
        let values2 = v.value;
        let field_value = (() => {
          let _pipe = values2;
          let _pipe$1 = key_find(_pipe, field_name);
          let _pipe$2 = replace_error(
            _pipe$1,
            toList([
              new DecodeError("Value", "None", toList([field_name]))
            ])
          );
          return then$(_pipe$2, field_type.decoder);
        })();
        return try$(field_value, (a) => {
          return next(a).decoder(v);
        });
      } else {
        return new Error(toList([]));
      }
    },
    prepend(
      [field_name, field_type.type_def],
      next(field_type.default_value).fields_def
    ),
    next(field_type.default_value).default_value
  );
}
function map5(converter, encode_map, decode_map2, default_value) {
  return new Converter(
    (v) => {
      let a_value = encode_map(v);
      return converter.encoder(a_value);
    },
    (v) => {
      let _pipe = converter.decoder(v);
      return then$(_pipe, decode_map2);
    },
    converter.type_def,
    default_value
  );
}
function encode(converter) {
  return converter.encoder;
}
function decode2(converter) {
  return converter.decoder;
}
function type_def(converter) {
  return converter.type_def;
}

// build/dev/javascript/gleamrpc/gleamrpc.mjs
var Query = class extends CustomType {
};
var Procedure = class extends CustomType {
  constructor(name, router, type_, params_type, return_type) {
    super();
    this.name = name;
    this.router = router;
    this.type_ = type_;
    this.params_type = params_type;
    this.return_type = return_type;
  }
};
var GleamRPCError = class extends CustomType {
  constructor(error2) {
    super();
    this.error = error2;
  }
};
var ProcedureClient = class extends CustomType {
  constructor(call3) {
    super();
    this.call = call3;
  }
};
var ProcedureCall = class extends CustomType {
  constructor(procedure, client2) {
    super();
    this.procedure = procedure;
    this.client = client2;
  }
};
function query(name, router) {
  return new Procedure(
    name,
    router,
    new Query(),
    null$2(),
    null$2()
  );
}
function params(procedure, params_converter) {
  let _record = procedure;
  return new Procedure(
    _record.name,
    _record.router,
    _record.type_,
    params_converter,
    _record.return_type
  );
}
function returns(procedure, return_converter) {
  let _record = procedure;
  return new Procedure(
    _record.name,
    _record.router,
    _record.type_,
    _record.params_type,
    return_converter
  );
}
function with_client(procedure, client2) {
  return new ProcedureCall(procedure, client2);
}
function call(procedure_call, params2, callback) {
  return procedure_call.client.call(procedure_call.procedure, params2, callback);
}

// build/dev/javascript/gleam_regexp/gleam_regexp_ffi.mjs
function check(regex, string3) {
  regex.lastIndex = 0;
  return regex.test(string3);
}
function compile(pattern, options) {
  try {
    let flags = "gu";
    if (options.case_insensitive)
      flags += "i";
    if (options.multi_line)
      flags += "m";
    return new Ok(new RegExp(pattern, flags));
  } catch (error2) {
    const number = (error2.columnNumber || 0) | 0;
    return new Error(new CompileError(error2.message, number));
  }
}

// build/dev/javascript/gleam_regexp/gleam/regexp.mjs
var CompileError = class extends CustomType {
  constructor(error2, byte_index) {
    super();
    this.error = error2;
    this.byte_index = byte_index;
  }
};
var Options = class extends CustomType {
  constructor(case_insensitive, multi_line) {
    super();
    this.case_insensitive = case_insensitive;
    this.multi_line = multi_line;
  }
};
function compile2(pattern, options) {
  return compile(pattern, options);
}
function from_string(pattern) {
  return compile2(pattern, new Options(false, false));
}
function check2(regexp, string3) {
  return check(regexp, string3);
}

// build/dev/javascript/shared/shared.mjs
var Uuid = class extends CustomType {
  constructor(data) {
    super();
    this.data = data;
  }
};
function uuid_converter() {
  let _pipe = string2();
  return map5(
    _pipe,
    (uuid) => {
      return uuid.data;
    },
    (v) => {
      let $ = from_string(
        "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
      );
      if (!$.isOk()) {
        throw makeError(
          "let_assert",
          "shared",
          15,
          "",
          "UUID regex should be valid !",
          { value: $ }
        );
      }
      let re = $[0];
      let $1 = (() => {
        let _pipe$1 = re;
        return check2(_pipe$1, v);
      })();
      if (!$1) {
        return new Error(
          toList([new DecodeError("A valid UUID", v, toList([]))])
        );
      } else {
        return new Ok(new Uuid(v));
      }
    },
    new Uuid("00000000-0000-0000-0000-000000000000")
  );
}

// build/dev/javascript/shared/shared/user.mjs
var User = class extends CustomType {
  constructor(id, pseudo) {
    super();
    this.id = id;
    this.pseudo = pseudo;
  }
};
var LoginData = class extends CustomType {
  constructor(pseudo, password) {
    super();
    this.pseudo = pseudo;
    this.password = password;
  }
};
function user_converter() {
  return object3(
    field2(
      "id",
      (v) => {
        return new Ok(v.id);
      },
      uuid_converter(),
      (id) => {
        return field2(
          "pseudo",
          (v) => {
            return new Ok(v.pseudo);
          },
          string2(),
          (pseudo) => {
            return success(new User(id, pseudo));
          }
        );
      }
    )
  );
}
function login_data_converter() {
  return object3(
    field2(
      "pseudo",
      (v) => {
        return new Ok(v.pseudo);
      },
      string2(),
      (pseudo) => {
        return field2(
          "password",
          (v) => {
            return new Ok(v.password);
          },
          string2(),
          (password) => {
            return success(new LoginData(pseudo, password));
          }
        );
      }
    )
  );
}
function login() {
  let _pipe = query("login", new None());
  let _pipe$1 = params(_pipe, login_data_converter());
  return returns(_pipe$1, user_converter());
}

// build/dev/javascript/client/client/model.mjs
var Model2 = class extends CustomType {
  constructor(user, qwizes) {
    super();
    this.user = user;
    this.qwizes = qwizes;
  }
};

// build/dev/javascript/client/client/msg.mjs
var Login = class extends CustomType {
  constructor(username, password) {
    super();
    this.username = username;
    this.password = password;
  }
};
var SetUser = class extends CustomType {
  constructor(user) {
    super();
    this.user = user;
  }
};

// build/dev/javascript/convert_http_query/convert/http/query.mjs
function encode_dict_key(key) {
  if (key instanceof BoolValue) {
    let v = key.value;
    return to_string2(v);
  } else if (key instanceof FloatValue) {
    let v = key.value;
    return float_to_string(v);
  } else if (key instanceof IntValue) {
    let v = key.value;
    return to_string(v);
  } else if (key instanceof StringValue) {
    let v = key.value;
    return v;
  } else if (key instanceof BitArrayValue) {
    let v = key.value;
    return base64_url_encode(v, true);
  } else {
    return "";
  }
}
function encode_sub_value(val, path) {
  let prefix = join(path, ".");
  if (val instanceof BoolValue) {
    let v = val.value;
    return toList([[prefix, to_string2(v)]]);
  } else if (val instanceof DictValue) {
    let v = val.value;
    return encode_dict(v, path);
  } else if (val instanceof EnumValue) {
    let variant = val.variant;
    let v = val.value;
    return encode_enum(variant, v, path);
  } else if (val instanceof FloatValue) {
    let v = val.value;
    return toList([[prefix, float_to_string(v)]]);
  } else if (val instanceof IntValue) {
    let v = val.value;
    return toList([[prefix, to_string(v)]]);
  } else if (val instanceof ListValue) {
    let v = val.value;
    return encode_list(v, path);
  } else if (val instanceof NullValue) {
    return toList([]);
  } else if (val instanceof ObjectValue) {
    let v = val.value;
    return encode_object(v, path);
  } else if (val instanceof OptionalValue) {
    let v = val.value;
    return encode_optional(v, path);
  } else if (val instanceof ResultValue) {
    let v = val.value;
    return encode_result(v, path);
  } else if (val instanceof StringValue) {
    let v = val.value;
    return toList([[prefix, v]]);
  } else if (val instanceof BitArrayValue) {
    let v = val.value;
    return toList([[prefix, base64_url_encode(v, true)]]);
  } else {
    return toList([]);
  }
}
function encode_dict(val, path) {
  let result_partition = (() => {
    let _pipe2 = val;
    let _pipe$12 = map_to_list(_pipe2);
    let _pipe$2 = map(
      _pipe$12,
      (kv) => {
        let $ = encode_dict_key(kv[0]);
        if ($ === "") {
          return new Error(void 0);
        } else {
          let key = $;
          return new Ok(
            encode_sub_value(kv[1], append(path, toList([key])))
          );
        }
      }
    );
    return partition(_pipe$2);
  })();
  let _pipe = result_partition[0];
  let _pipe$1 = reverse(_pipe);
  return flatten(_pipe$1);
}
function encode_object(val, path) {
  let _pipe = val;
  return flat_map(
    _pipe,
    (value) => {
      return encode_sub_value(value[1], append(path, toList([value[0]])));
    }
  );
}
function encode_list(val, path) {
  let _pipe = val;
  let _pipe$1 = index_fold(
    _pipe,
    toList([]),
    (acc, value, index3) => {
      return flatten(
        toList([
          encode_sub_value(
            value,
            append(path, toList([to_string(index3)]))
          ),
          acc
        ])
      );
    }
  );
  return reverse(_pipe$1);
}
function encode_result(val, path) {
  if (val.isOk()) {
    let v = val[0];
    return encode_sub_value(v, append(path, toList(["ok"])));
  } else {
    let v = val[0];
    return encode_sub_value(v, append(path, toList(["error"])));
  }
}
function encode_optional(val, path) {
  if (val instanceof None) {
    return toList([]);
  } else {
    let v = val[0];
    return encode_sub_value(v, path);
  }
}
function encode_enum(variant, v, path) {
  return encode_sub_value(v, append(path, toList([variant])));
}
function encode_value(val) {
  if (val instanceof BoolValue) {
    let v = val.value;
    return toList([["bool", to_string2(v)]]);
  } else if (val instanceof DictValue) {
    let v = val.value;
    return encode_dict(v, toList(["dict"]));
  } else if (val instanceof EnumValue) {
    let variant = val.variant;
    let v = val.value;
    return encode_enum(variant, v, toList([]));
  } else if (val instanceof FloatValue) {
    let v = val.value;
    return toList([["float", float_to_string(v)]]);
  } else if (val instanceof IntValue) {
    let v = val.value;
    return toList([["int", to_string(v)]]);
  } else if (val instanceof ListValue) {
    let v = val.value;
    return encode_list(v, toList(["list"]));
  } else if (val instanceof NullValue) {
    return toList([]);
  } else if (val instanceof ObjectValue) {
    let v = val.value;
    return encode_object(v, toList([]));
  } else if (val instanceof OptionalValue) {
    let v = val.value;
    return encode_optional(v, toList(["optional"]));
  } else if (val instanceof ResultValue) {
    let v = val.value;
    return encode_result(v, toList(["result"]));
  } else if (val instanceof StringValue) {
    let v = val.value;
    return toList([["string", v]]);
  } else if (val instanceof BitArrayValue) {
    let v = val.value;
    return toList([["bit_array", base64_url_encode(v, true)]]);
  } else {
    return toList([]);
  }
}
function encode2(value, converter) {
  let _pipe = value;
  let _pipe$1 = encode(converter)(_pipe);
  return encode_value(_pipe$1);
}

// build/dev/javascript/convert_json/convert/json.mjs
function encode_value2(val) {
  if (val instanceof StringValue) {
    let v = val.value;
    return string(v);
  } else if (val instanceof BoolValue) {
    let v = val.value;
    return bool2(v);
  } else if (val instanceof FloatValue) {
    let v = val.value;
    return float2(v);
  } else if (val instanceof IntValue) {
    let v = val.value;
    return int2(v);
  } else if (val instanceof ListValue) {
    let vals = val.value;
    return array2(vals, encode_value2);
  } else if (val instanceof DictValue) {
    let v = val.value;
    return array2(
      (() => {
        let _pipe = v;
        return map_to_list(_pipe);
      })(),
      (keyval) => {
        return array2(toList([keyval[0], keyval[1]]), encode_value2);
      }
    );
  } else if (val instanceof ObjectValue) {
    let v = val.value;
    return object2(
      map(v, (f) => {
        return [f[0], encode_value2(f[1])];
      })
    );
  } else if (val instanceof OptionalValue) {
    let v = val.value;
    return nullable(v, encode_value2);
  } else if (val instanceof ResultValue) {
    let v = val.value;
    if (v.isOk()) {
      let res = v[0];
      return object2(
        toList([["type", string("ok")], ["value", encode_value2(res)]])
      );
    } else {
      let err = v[0];
      return object2(
        toList([["type", string("error")], ["value", encode_value2(err)]])
      );
    }
  } else if (val instanceof EnumValue) {
    let variant = val.variant;
    let v = val.value;
    return object2(
      toList([["variant", string(variant)], ["value", encode_value2(v)]])
    );
  } else if (val instanceof BitArrayValue) {
    let v = val.value;
    return string(base64_url_encode(v, true));
  } else {
    return null$();
  }
}
function json_encode(value, converter) {
  let _pipe = value;
  let _pipe$1 = encode(converter)(_pipe);
  return encode_value2(_pipe$1);
}
function decode_value(of) {
  if (of instanceof String2) {
    return (val) => {
      let _pipe = val;
      let _pipe$1 = decode_string(_pipe);
      return map2(
        _pipe$1,
        (var0) => {
          return new StringValue(var0);
        }
      );
    };
  } else if (of instanceof Bool) {
    return (val) => {
      let _pipe = val;
      let _pipe$1 = bool(_pipe);
      return map2(_pipe$1, (var0) => {
        return new BoolValue(var0);
      });
    };
  } else if (of instanceof Float) {
    return (val) => {
      let _pipe = val;
      let _pipe$1 = float(_pipe);
      return map2(_pipe$1, (var0) => {
        return new FloatValue(var0);
      });
    };
  } else if (of instanceof Int) {
    return (val) => {
      let _pipe = val;
      let _pipe$1 = int(_pipe);
      return map2(_pipe$1, (var0) => {
        return new IntValue(var0);
      });
    };
  } else if (of instanceof List2) {
    let el = of.of;
    return (val) => {
      let _pipe = val;
      let _pipe$1 = list(dynamic)(_pipe);
      let _pipe$2 = then$(
        _pipe$1,
        (val_list) => {
          return fold(
            val_list,
            new Ok(toList([])),
            (result, list_el) => {
              let $ = (() => {
                let _pipe$22 = list_el;
                return decode_value(el)(_pipe$22);
              })();
              if (result.isOk() && $.isOk()) {
                let result_list = result[0];
                let jval = $[0];
                return new Ok(prepend(jval, result_list));
              } else if (result.isOk() && !$.isOk()) {
                let errs = $[0];
                return new Error(errs);
              } else if (!result.isOk() && $.isOk()) {
                let errs = result[0];
                return new Error(errs);
              } else {
                let errs = result[0];
                let new_errs = $[0];
                return new Error(append(errs, new_errs));
              }
            }
          );
        }
      );
      let _pipe$3 = map2(_pipe$2, reverse);
      return map2(_pipe$3, (var0) => {
        return new ListValue(var0);
      });
    };
  } else if (of instanceof Dict2) {
    let k = of.key;
    let v = of.value;
    return (val) => {
      let _pipe = val;
      let _pipe$1 = list(
        list(any(toList([decode_value(k), decode_value(v)])))
      )(_pipe);
      let _pipe$2 = then$(
        _pipe$1,
        (_capture) => {
          return fold(
            _capture,
            new Ok(toList([])),
            (result, el) => {
              if (result.isOk() && el.atLeastLength(2)) {
                let vals = result[0];
                let first2 = el.head;
                let second = el.tail.head;
                return new Ok(prepend([first2, second], vals));
              } else if (result.isOk()) {
                return new Error(
                  toList([
                    new DecodeError("2 elements", "0 or 1", toList([]))
                  ])
                );
              } else if (!result.isOk() && el.atLeastLength(2)) {
                let errs = result[0];
                return new Error(errs);
              } else {
                let errs = result[0];
                return new Error(
                  prepend(
                    new DecodeError("2 elements", "0 or 1", toList([])),
                    errs
                  )
                );
              }
            }
          );
        }
      );
      let _pipe$3 = map2(_pipe$2, from_list);
      return map2(_pipe$3, (var0) => {
        return new DictValue(var0);
      });
    };
  } else if (of instanceof Object2) {
    let fields = of.fields;
    return (val) => {
      let _pipe = fold(
        fields,
        new Ok(toList([])),
        (result, f) => {
          let $ = (() => {
            let _pipe2 = val;
            return field(f[0], decode_value(f[1]))(_pipe2);
          })();
          if (result.isOk() && $.isOk()) {
            let field_list = result[0];
            let jval = $[0];
            return new Ok(prepend([f[0], jval], field_list));
          } else if (result.isOk() && !$.isOk()) {
            let errs = $[0];
            return new Error(errs);
          } else if (!result.isOk() && $.isOk()) {
            let errs = result[0];
            return new Error(errs);
          } else {
            let errs = result[0];
            let new_errs = $[0];
            return new Error(append(errs, new_errs));
          }
        }
      );
      let _pipe$1 = map2(_pipe, reverse);
      return map2(
        _pipe$1,
        (var0) => {
          return new ObjectValue(var0);
        }
      );
    };
  } else if (of instanceof Optional) {
    let of$1 = of.of;
    return (val) => {
      let _pipe = val;
      let _pipe$1 = optional(decode_value(of$1))(_pipe);
      return map2(
        _pipe$1,
        (var0) => {
          return new OptionalValue(var0);
        }
      );
    };
  } else if (of instanceof Result2) {
    let res = of.result;
    let err = of.error;
    return (val) => {
      return try$(
        (() => {
          let _pipe = val;
          return field("type", decode_string)(_pipe);
        })(),
        (type_val) => {
          if (type_val === "ok") {
            let _pipe = val;
            let _pipe$1 = field("value", decode_value(res))(_pipe);
            let _pipe$2 = map2(
              _pipe$1,
              (var0) => {
                return new Ok(var0);
              }
            );
            return map2(
              _pipe$2,
              (var0) => {
                return new ResultValue(var0);
              }
            );
          } else if (type_val === "error") {
            let _pipe = val;
            let _pipe$1 = field("value", decode_value(err))(_pipe);
            let _pipe$2 = map2(
              _pipe$1,
              (var0) => {
                return new Error(var0);
              }
            );
            return map2(
              _pipe$2,
              (var0) => {
                return new ResultValue(var0);
              }
            );
          } else {
            let other = type_val;
            return new Error(
              toList([
                new DecodeError(
                  "'ok' or 'error'",
                  other,
                  toList(["type"])
                )
              ])
            );
          }
        }
      );
    };
  } else if (of instanceof Enum) {
    let variants = of.variants;
    return (val) => {
      return try$(
        (() => {
          let _pipe = val;
          return field("variant", decode_string)(_pipe);
        })(),
        (variant_name) => {
          return try$(
            (() => {
              let _pipe = key_find(variants, variant_name);
              return replace_error(
                _pipe,
                toList([
                  new DecodeError(
                    "One of: " + (() => {
                      let _pipe$1 = variants;
                      let _pipe$2 = map(_pipe$1, (v) => {
                        return v[0];
                      });
                      return join(_pipe$2, "/");
                    })(),
                    variant_name,
                    toList(["variant"])
                  )
                ])
              );
            })(),
            (variant_def) => {
              return try$(
                (() => {
                  let _pipe = val;
                  let _pipe$1 = field("value", dynamic)(_pipe);
                  return then$(_pipe$1, decode_value(variant_def));
                })(),
                (variant_value) => {
                  return new Ok(new EnumValue(variant_name, variant_value));
                }
              );
            }
          );
        }
      );
    };
  } else if (of instanceof BitArray2) {
    return (val) => {
      let _pipe = val;
      let _pipe$1 = decode_string(_pipe);
      let _pipe$2 = then$(
        _pipe$1,
        (v) => {
          let _pipe$22 = base64_url_decode(v);
          return replace_error(
            _pipe$22,
            toList([new DecodeError("Base64Url", v, toList([]))])
          );
        }
      );
      return map2(
        _pipe$2,
        (var0) => {
          return new BitArrayValue(var0);
        }
      );
    };
  } else {
    return (_) => {
      return new Ok(new NullValue());
    };
  }
}
function json_decode(converter) {
  return (value) => {
    let _pipe = value;
    let _pipe$1 = decode_value(type_def(converter))(_pipe);
    return then$(_pipe$1, decode2(converter));
  };
}

// build/dev/javascript/gleam_stdlib/gleam/uri.mjs
var Uri = class extends CustomType {
  constructor(scheme, userinfo, host, port, path, query2, fragment) {
    super();
    this.scheme = scheme;
    this.userinfo = userinfo;
    this.host = host;
    this.port = port;
    this.path = path;
    this.query = query2;
    this.fragment = fragment;
  }
};
function is_valid_host_within_brackets_char(char) {
  return 48 >= char && char <= 57 || 65 >= char && char <= 90 || 97 >= char && char <= 122 || char === 58 || char === 46;
}
function parse_fragment(rest, pieces) {
  return new Ok(
    (() => {
      let _record = pieces;
      return new Uri(
        _record.scheme,
        _record.userinfo,
        _record.host,
        _record.port,
        _record.path,
        _record.query,
        new Some(rest)
      );
    })()
  );
}
function parse_query_with_question_mark_loop(loop$original, loop$uri_string, loop$pieces, loop$size) {
  while (true) {
    let original = loop$original;
    let uri_string = loop$uri_string;
    let pieces = loop$pieces;
    let size = loop$size;
    if (uri_string.startsWith("#") && size === 0) {
      let rest = uri_string.slice(1);
      return parse_fragment(rest, pieces);
    } else if (uri_string.startsWith("#")) {
      let rest = uri_string.slice(1);
      let query2 = string_codeunit_slice(original, 0, size);
      let pieces$1 = (() => {
        let _record = pieces;
        return new Uri(
          _record.scheme,
          _record.userinfo,
          _record.host,
          _record.port,
          _record.path,
          new Some(query2),
          _record.fragment
        );
      })();
      return parse_fragment(rest, pieces$1);
    } else if (uri_string === "") {
      return new Ok(
        (() => {
          let _record = pieces;
          return new Uri(
            _record.scheme,
            _record.userinfo,
            _record.host,
            _record.port,
            _record.path,
            new Some(original),
            _record.fragment
          );
        })()
      );
    } else {
      let $ = pop_codeunit(uri_string);
      let rest = $[1];
      loop$original = original;
      loop$uri_string = rest;
      loop$pieces = pieces;
      loop$size = size + 1;
    }
  }
}
function parse_query_with_question_mark(uri_string, pieces) {
  return parse_query_with_question_mark_loop(uri_string, uri_string, pieces, 0);
}
function parse_path_loop(loop$original, loop$uri_string, loop$pieces, loop$size) {
  while (true) {
    let original = loop$original;
    let uri_string = loop$uri_string;
    let pieces = loop$pieces;
    let size = loop$size;
    if (uri_string.startsWith("?")) {
      let rest = uri_string.slice(1);
      let path = string_codeunit_slice(original, 0, size);
      let pieces$1 = (() => {
        let _record = pieces;
        return new Uri(
          _record.scheme,
          _record.userinfo,
          _record.host,
          _record.port,
          path,
          _record.query,
          _record.fragment
        );
      })();
      return parse_query_with_question_mark(rest, pieces$1);
    } else if (uri_string.startsWith("#")) {
      let rest = uri_string.slice(1);
      let path = string_codeunit_slice(original, 0, size);
      let pieces$1 = (() => {
        let _record = pieces;
        return new Uri(
          _record.scheme,
          _record.userinfo,
          _record.host,
          _record.port,
          path,
          _record.query,
          _record.fragment
        );
      })();
      return parse_fragment(rest, pieces$1);
    } else if (uri_string === "") {
      return new Ok(
        (() => {
          let _record = pieces;
          return new Uri(
            _record.scheme,
            _record.userinfo,
            _record.host,
            _record.port,
            original,
            _record.query,
            _record.fragment
          );
        })()
      );
    } else {
      let $ = pop_codeunit(uri_string);
      let rest = $[1];
      loop$original = original;
      loop$uri_string = rest;
      loop$pieces = pieces;
      loop$size = size + 1;
    }
  }
}
function parse_path(uri_string, pieces) {
  return parse_path_loop(uri_string, uri_string, pieces, 0);
}
function parse_port_loop(loop$uri_string, loop$pieces, loop$port) {
  while (true) {
    let uri_string = loop$uri_string;
    let pieces = loop$pieces;
    let port = loop$port;
    if (uri_string.startsWith("0")) {
      let rest = uri_string.slice(1);
      loop$uri_string = rest;
      loop$pieces = pieces;
      loop$port = port * 10;
    } else if (uri_string.startsWith("1")) {
      let rest = uri_string.slice(1);
      loop$uri_string = rest;
      loop$pieces = pieces;
      loop$port = port * 10 + 1;
    } else if (uri_string.startsWith("2")) {
      let rest = uri_string.slice(1);
      loop$uri_string = rest;
      loop$pieces = pieces;
      loop$port = port * 10 + 2;
    } else if (uri_string.startsWith("3")) {
      let rest = uri_string.slice(1);
      loop$uri_string = rest;
      loop$pieces = pieces;
      loop$port = port * 10 + 3;
    } else if (uri_string.startsWith("4")) {
      let rest = uri_string.slice(1);
      loop$uri_string = rest;
      loop$pieces = pieces;
      loop$port = port * 10 + 4;
    } else if (uri_string.startsWith("5")) {
      let rest = uri_string.slice(1);
      loop$uri_string = rest;
      loop$pieces = pieces;
      loop$port = port * 10 + 5;
    } else if (uri_string.startsWith("6")) {
      let rest = uri_string.slice(1);
      loop$uri_string = rest;
      loop$pieces = pieces;
      loop$port = port * 10 + 6;
    } else if (uri_string.startsWith("7")) {
      let rest = uri_string.slice(1);
      loop$uri_string = rest;
      loop$pieces = pieces;
      loop$port = port * 10 + 7;
    } else if (uri_string.startsWith("8")) {
      let rest = uri_string.slice(1);
      loop$uri_string = rest;
      loop$pieces = pieces;
      loop$port = port * 10 + 8;
    } else if (uri_string.startsWith("9")) {
      let rest = uri_string.slice(1);
      loop$uri_string = rest;
      loop$pieces = pieces;
      loop$port = port * 10 + 9;
    } else if (uri_string.startsWith("?")) {
      let rest = uri_string.slice(1);
      let pieces$1 = (() => {
        let _record = pieces;
        return new Uri(
          _record.scheme,
          _record.userinfo,
          _record.host,
          new Some(port),
          _record.path,
          _record.query,
          _record.fragment
        );
      })();
      return parse_query_with_question_mark(rest, pieces$1);
    } else if (uri_string.startsWith("#")) {
      let rest = uri_string.slice(1);
      let pieces$1 = (() => {
        let _record = pieces;
        return new Uri(
          _record.scheme,
          _record.userinfo,
          _record.host,
          new Some(port),
          _record.path,
          _record.query,
          _record.fragment
        );
      })();
      return parse_fragment(rest, pieces$1);
    } else if (uri_string.startsWith("/")) {
      let pieces$1 = (() => {
        let _record = pieces;
        return new Uri(
          _record.scheme,
          _record.userinfo,
          _record.host,
          new Some(port),
          _record.path,
          _record.query,
          _record.fragment
        );
      })();
      return parse_path(uri_string, pieces$1);
    } else if (uri_string === "") {
      return new Ok(
        (() => {
          let _record = pieces;
          return new Uri(
            _record.scheme,
            _record.userinfo,
            _record.host,
            new Some(port),
            _record.path,
            _record.query,
            _record.fragment
          );
        })()
      );
    } else {
      return new Error(void 0);
    }
  }
}
function parse_port(uri_string, pieces) {
  if (uri_string.startsWith(":0")) {
    let rest = uri_string.slice(2);
    return parse_port_loop(rest, pieces, 0);
  } else if (uri_string.startsWith(":1")) {
    let rest = uri_string.slice(2);
    return parse_port_loop(rest, pieces, 1);
  } else if (uri_string.startsWith(":2")) {
    let rest = uri_string.slice(2);
    return parse_port_loop(rest, pieces, 2);
  } else if (uri_string.startsWith(":3")) {
    let rest = uri_string.slice(2);
    return parse_port_loop(rest, pieces, 3);
  } else if (uri_string.startsWith(":4")) {
    let rest = uri_string.slice(2);
    return parse_port_loop(rest, pieces, 4);
  } else if (uri_string.startsWith(":5")) {
    let rest = uri_string.slice(2);
    return parse_port_loop(rest, pieces, 5);
  } else if (uri_string.startsWith(":6")) {
    let rest = uri_string.slice(2);
    return parse_port_loop(rest, pieces, 6);
  } else if (uri_string.startsWith(":7")) {
    let rest = uri_string.slice(2);
    return parse_port_loop(rest, pieces, 7);
  } else if (uri_string.startsWith(":8")) {
    let rest = uri_string.slice(2);
    return parse_port_loop(rest, pieces, 8);
  } else if (uri_string.startsWith(":9")) {
    let rest = uri_string.slice(2);
    return parse_port_loop(rest, pieces, 9);
  } else if (uri_string.startsWith(":")) {
    return new Error(void 0);
  } else if (uri_string.startsWith("?")) {
    let rest = uri_string.slice(1);
    return parse_query_with_question_mark(rest, pieces);
  } else if (uri_string.startsWith("#")) {
    let rest = uri_string.slice(1);
    return parse_fragment(rest, pieces);
  } else if (uri_string.startsWith("/")) {
    return parse_path(uri_string, pieces);
  } else if (uri_string === "") {
    return new Ok(pieces);
  } else {
    return new Error(void 0);
  }
}
function parse_host_outside_of_brackets_loop(loop$original, loop$uri_string, loop$pieces, loop$size) {
  while (true) {
    let original = loop$original;
    let uri_string = loop$uri_string;
    let pieces = loop$pieces;
    let size = loop$size;
    if (uri_string === "") {
      return new Ok(
        (() => {
          let _record = pieces;
          return new Uri(
            _record.scheme,
            _record.userinfo,
            new Some(original),
            _record.port,
            _record.path,
            _record.query,
            _record.fragment
          );
        })()
      );
    } else if (uri_string.startsWith(":")) {
      let host = string_codeunit_slice(original, 0, size);
      let pieces$1 = (() => {
        let _record = pieces;
        return new Uri(
          _record.scheme,
          _record.userinfo,
          new Some(host),
          _record.port,
          _record.path,
          _record.query,
          _record.fragment
        );
      })();
      return parse_port(uri_string, pieces$1);
    } else if (uri_string.startsWith("/")) {
      let host = string_codeunit_slice(original, 0, size);
      let pieces$1 = (() => {
        let _record = pieces;
        return new Uri(
          _record.scheme,
          _record.userinfo,
          new Some(host),
          _record.port,
          _record.path,
          _record.query,
          _record.fragment
        );
      })();
      return parse_path(uri_string, pieces$1);
    } else if (uri_string.startsWith("?")) {
      let rest = uri_string.slice(1);
      let host = string_codeunit_slice(original, 0, size);
      let pieces$1 = (() => {
        let _record = pieces;
        return new Uri(
          _record.scheme,
          _record.userinfo,
          new Some(host),
          _record.port,
          _record.path,
          _record.query,
          _record.fragment
        );
      })();
      return parse_query_with_question_mark(rest, pieces$1);
    } else if (uri_string.startsWith("#")) {
      let rest = uri_string.slice(1);
      let host = string_codeunit_slice(original, 0, size);
      let pieces$1 = (() => {
        let _record = pieces;
        return new Uri(
          _record.scheme,
          _record.userinfo,
          new Some(host),
          _record.port,
          _record.path,
          _record.query,
          _record.fragment
        );
      })();
      return parse_fragment(rest, pieces$1);
    } else {
      let $ = pop_codeunit(uri_string);
      let rest = $[1];
      loop$original = original;
      loop$uri_string = rest;
      loop$pieces = pieces;
      loop$size = size + 1;
    }
  }
}
function parse_host_within_brackets_loop(loop$original, loop$uri_string, loop$pieces, loop$size) {
  while (true) {
    let original = loop$original;
    let uri_string = loop$uri_string;
    let pieces = loop$pieces;
    let size = loop$size;
    if (uri_string === "") {
      return new Ok(
        (() => {
          let _record = pieces;
          return new Uri(
            _record.scheme,
            _record.userinfo,
            new Some(uri_string),
            _record.port,
            _record.path,
            _record.query,
            _record.fragment
          );
        })()
      );
    } else if (uri_string.startsWith("]") && size === 0) {
      let rest = uri_string.slice(1);
      return parse_port(rest, pieces);
    } else if (uri_string.startsWith("]")) {
      let rest = uri_string.slice(1);
      let host = string_codeunit_slice(original, 0, size + 1);
      let pieces$1 = (() => {
        let _record = pieces;
        return new Uri(
          _record.scheme,
          _record.userinfo,
          new Some(host),
          _record.port,
          _record.path,
          _record.query,
          _record.fragment
        );
      })();
      return parse_port(rest, pieces$1);
    } else if (uri_string.startsWith("/") && size === 0) {
      return parse_path(uri_string, pieces);
    } else if (uri_string.startsWith("/")) {
      let host = string_codeunit_slice(original, 0, size);
      let pieces$1 = (() => {
        let _record = pieces;
        return new Uri(
          _record.scheme,
          _record.userinfo,
          new Some(host),
          _record.port,
          _record.path,
          _record.query,
          _record.fragment
        );
      })();
      return parse_path(uri_string, pieces$1);
    } else if (uri_string.startsWith("?") && size === 0) {
      let rest = uri_string.slice(1);
      return parse_query_with_question_mark(rest, pieces);
    } else if (uri_string.startsWith("?")) {
      let rest = uri_string.slice(1);
      let host = string_codeunit_slice(original, 0, size);
      let pieces$1 = (() => {
        let _record = pieces;
        return new Uri(
          _record.scheme,
          _record.userinfo,
          new Some(host),
          _record.port,
          _record.path,
          _record.query,
          _record.fragment
        );
      })();
      return parse_query_with_question_mark(rest, pieces$1);
    } else if (uri_string.startsWith("#") && size === 0) {
      let rest = uri_string.slice(1);
      return parse_fragment(rest, pieces);
    } else if (uri_string.startsWith("#")) {
      let rest = uri_string.slice(1);
      let host = string_codeunit_slice(original, 0, size);
      let pieces$1 = (() => {
        let _record = pieces;
        return new Uri(
          _record.scheme,
          _record.userinfo,
          new Some(host),
          _record.port,
          _record.path,
          _record.query,
          _record.fragment
        );
      })();
      return parse_fragment(rest, pieces$1);
    } else {
      let $ = pop_codeunit(uri_string);
      let char = $[0];
      let rest = $[1];
      let $1 = is_valid_host_within_brackets_char(char);
      if ($1) {
        loop$original = original;
        loop$uri_string = rest;
        loop$pieces = pieces;
        loop$size = size + 1;
      } else {
        return parse_host_outside_of_brackets_loop(
          original,
          original,
          pieces,
          0
        );
      }
    }
  }
}
function parse_host_within_brackets(uri_string, pieces) {
  return parse_host_within_brackets_loop(uri_string, uri_string, pieces, 0);
}
function parse_host_outside_of_brackets(uri_string, pieces) {
  return parse_host_outside_of_brackets_loop(uri_string, uri_string, pieces, 0);
}
function parse_host(uri_string, pieces) {
  if (uri_string.startsWith("[")) {
    return parse_host_within_brackets(uri_string, pieces);
  } else if (uri_string.startsWith(":")) {
    let pieces$1 = (() => {
      let _record = pieces;
      return new Uri(
        _record.scheme,
        _record.userinfo,
        new Some(""),
        _record.port,
        _record.path,
        _record.query,
        _record.fragment
      );
    })();
    return parse_port(uri_string, pieces$1);
  } else if (uri_string === "") {
    return new Ok(
      (() => {
        let _record = pieces;
        return new Uri(
          _record.scheme,
          _record.userinfo,
          new Some(""),
          _record.port,
          _record.path,
          _record.query,
          _record.fragment
        );
      })()
    );
  } else {
    return parse_host_outside_of_brackets(uri_string, pieces);
  }
}
function parse_userinfo_loop(loop$original, loop$uri_string, loop$pieces, loop$size) {
  while (true) {
    let original = loop$original;
    let uri_string = loop$uri_string;
    let pieces = loop$pieces;
    let size = loop$size;
    if (uri_string.startsWith("@") && size === 0) {
      let rest = uri_string.slice(1);
      return parse_host(rest, pieces);
    } else if (uri_string.startsWith("@")) {
      let rest = uri_string.slice(1);
      let userinfo = string_codeunit_slice(original, 0, size);
      let pieces$1 = (() => {
        let _record = pieces;
        return new Uri(
          _record.scheme,
          new Some(userinfo),
          _record.host,
          _record.port,
          _record.path,
          _record.query,
          _record.fragment
        );
      })();
      return parse_host(rest, pieces$1);
    } else if (uri_string === "") {
      return parse_host(original, pieces);
    } else if (uri_string.startsWith("/")) {
      return parse_host(original, pieces);
    } else if (uri_string.startsWith("?")) {
      return parse_host(original, pieces);
    } else if (uri_string.startsWith("#")) {
      return parse_host(original, pieces);
    } else {
      let $ = pop_codeunit(uri_string);
      let rest = $[1];
      loop$original = original;
      loop$uri_string = rest;
      loop$pieces = pieces;
      loop$size = size + 1;
    }
  }
}
function parse_authority_pieces(string3, pieces) {
  return parse_userinfo_loop(string3, string3, pieces, 0);
}
function parse_authority_with_slashes(uri_string, pieces) {
  if (uri_string === "//") {
    return new Ok(
      (() => {
        let _record = pieces;
        return new Uri(
          _record.scheme,
          _record.userinfo,
          new Some(""),
          _record.port,
          _record.path,
          _record.query,
          _record.fragment
        );
      })()
    );
  } else if (uri_string.startsWith("//")) {
    let rest = uri_string.slice(2);
    return parse_authority_pieces(rest, pieces);
  } else {
    return parse_path(uri_string, pieces);
  }
}
function parse_scheme_loop(loop$original, loop$uri_string, loop$pieces, loop$size) {
  while (true) {
    let original = loop$original;
    let uri_string = loop$uri_string;
    let pieces = loop$pieces;
    let size = loop$size;
    if (uri_string.startsWith("/") && size === 0) {
      return parse_authority_with_slashes(uri_string, pieces);
    } else if (uri_string.startsWith("/")) {
      let scheme = string_codeunit_slice(original, 0, size);
      let pieces$1 = (() => {
        let _record = pieces;
        return new Uri(
          new Some(lowercase(scheme)),
          _record.userinfo,
          _record.host,
          _record.port,
          _record.path,
          _record.query,
          _record.fragment
        );
      })();
      return parse_authority_with_slashes(uri_string, pieces$1);
    } else if (uri_string.startsWith("?") && size === 0) {
      let rest = uri_string.slice(1);
      return parse_query_with_question_mark(rest, pieces);
    } else if (uri_string.startsWith("?")) {
      let rest = uri_string.slice(1);
      let scheme = string_codeunit_slice(original, 0, size);
      let pieces$1 = (() => {
        let _record = pieces;
        return new Uri(
          new Some(lowercase(scheme)),
          _record.userinfo,
          _record.host,
          _record.port,
          _record.path,
          _record.query,
          _record.fragment
        );
      })();
      return parse_query_with_question_mark(rest, pieces$1);
    } else if (uri_string.startsWith("#") && size === 0) {
      let rest = uri_string.slice(1);
      return parse_fragment(rest, pieces);
    } else if (uri_string.startsWith("#")) {
      let rest = uri_string.slice(1);
      let scheme = string_codeunit_slice(original, 0, size);
      let pieces$1 = (() => {
        let _record = pieces;
        return new Uri(
          new Some(lowercase(scheme)),
          _record.userinfo,
          _record.host,
          _record.port,
          _record.path,
          _record.query,
          _record.fragment
        );
      })();
      return parse_fragment(rest, pieces$1);
    } else if (uri_string.startsWith(":") && size === 0) {
      return new Error(void 0);
    } else if (uri_string.startsWith(":")) {
      let rest = uri_string.slice(1);
      let scheme = string_codeunit_slice(original, 0, size);
      let pieces$1 = (() => {
        let _record = pieces;
        return new Uri(
          new Some(lowercase(scheme)),
          _record.userinfo,
          _record.host,
          _record.port,
          _record.path,
          _record.query,
          _record.fragment
        );
      })();
      return parse_authority_with_slashes(rest, pieces$1);
    } else if (uri_string === "") {
      return new Ok(
        (() => {
          let _record = pieces;
          return new Uri(
            _record.scheme,
            _record.userinfo,
            _record.host,
            _record.port,
            original,
            _record.query,
            _record.fragment
          );
        })()
      );
    } else {
      let $ = pop_codeunit(uri_string);
      let rest = $[1];
      loop$original = original;
      loop$uri_string = rest;
      loop$pieces = pieces;
      loop$size = size + 1;
    }
  }
}
function parse(uri_string) {
  let default_pieces = new Uri(
    new None(),
    new None(),
    new None(),
    new None(),
    "",
    new None(),
    new None()
  );
  return parse_scheme_loop(uri_string, uri_string, default_pieces, 0);
}
function to_string4(uri) {
  let parts = (() => {
    let $ = uri.fragment;
    if ($ instanceof Some) {
      let fragment = $[0];
      return toList(["#", fragment]);
    } else {
      return toList([]);
    }
  })();
  let parts$1 = (() => {
    let $ = uri.query;
    if ($ instanceof Some) {
      let query2 = $[0];
      return prepend("?", prepend(query2, parts));
    } else {
      return parts;
    }
  })();
  let parts$2 = prepend(uri.path, parts$1);
  let parts$3 = (() => {
    let $ = uri.host;
    let $1 = starts_with(uri.path, "/");
    if ($ instanceof Some && !$1 && $[0] !== "") {
      let host = $[0];
      return prepend("/", parts$2);
    } else {
      return parts$2;
    }
  })();
  let parts$4 = (() => {
    let $ = uri.host;
    let $1 = uri.port;
    if ($ instanceof Some && $1 instanceof Some) {
      let port = $1[0];
      return prepend(":", prepend(to_string(port), parts$3));
    } else {
      return parts$3;
    }
  })();
  let parts$5 = (() => {
    let $ = uri.scheme;
    let $1 = uri.userinfo;
    let $2 = uri.host;
    if ($ instanceof Some && $1 instanceof Some && $2 instanceof Some) {
      let s = $[0];
      let u = $1[0];
      let h = $2[0];
      return prepend(
        s,
        prepend(
          "://",
          prepend(u, prepend("@", prepend(h, parts$4)))
        )
      );
    } else if ($ instanceof Some && $1 instanceof None && $2 instanceof Some) {
      let s = $[0];
      let h = $2[0];
      return prepend(s, prepend("://", prepend(h, parts$4)));
    } else if ($ instanceof Some && $1 instanceof Some && $2 instanceof None) {
      let s = $[0];
      return prepend(s, prepend(":", parts$4));
    } else if ($ instanceof Some && $1 instanceof None && $2 instanceof None) {
      let s = $[0];
      return prepend(s, prepend(":", parts$4));
    } else if ($ instanceof None && $1 instanceof None && $2 instanceof Some) {
      let h = $2[0];
      return prepend("//", prepend(h, parts$4));
    } else {
      return parts$4;
    }
  })();
  return concat2(parts$5);
}

// build/dev/javascript/gleam_http/gleam/http.mjs
var Get = class extends CustomType {
};
var Post = class extends CustomType {
};
var Head = class extends CustomType {
};
var Put = class extends CustomType {
};
var Delete = class extends CustomType {
};
var Trace = class extends CustomType {
};
var Connect = class extends CustomType {
};
var Options2 = class extends CustomType {
};
var Patch = class extends CustomType {
};
var Http = class extends CustomType {
};
var Https = class extends CustomType {
};
function method_to_string(method) {
  if (method instanceof Connect) {
    return "connect";
  } else if (method instanceof Delete) {
    return "delete";
  } else if (method instanceof Get) {
    return "get";
  } else if (method instanceof Head) {
    return "head";
  } else if (method instanceof Options2) {
    return "options";
  } else if (method instanceof Patch) {
    return "patch";
  } else if (method instanceof Post) {
    return "post";
  } else if (method instanceof Put) {
    return "put";
  } else if (method instanceof Trace) {
    return "trace";
  } else {
    let s = method[0];
    return s;
  }
}
function scheme_to_string(scheme) {
  if (scheme instanceof Http) {
    return "http";
  } else {
    return "https";
  }
}
function scheme_from_string(scheme) {
  let $ = lowercase(scheme);
  if ($ === "http") {
    return new Ok(new Http());
  } else if ($ === "https") {
    return new Ok(new Https());
  } else {
    return new Error(void 0);
  }
}

// build/dev/javascript/gleam_http/gleam/http/request.mjs
var Request = class extends CustomType {
  constructor(method, headers, body, scheme, host, port, path, query2) {
    super();
    this.method = method;
    this.headers = headers;
    this.body = body;
    this.scheme = scheme;
    this.host = host;
    this.port = port;
    this.path = path;
    this.query = query2;
  }
};
function to_uri(request) {
  return new Uri(
    new Some(scheme_to_string(request.scheme)),
    new None(),
    new Some(request.host),
    request.port,
    request.path,
    request.query,
    new None()
  );
}
function from_uri(uri) {
  return then$(
    (() => {
      let _pipe = uri.scheme;
      let _pipe$1 = unwrap(_pipe, "");
      return scheme_from_string(_pipe$1);
    })(),
    (scheme) => {
      return then$(
        (() => {
          let _pipe = uri.host;
          return to_result(_pipe, void 0);
        })(),
        (host) => {
          let req = new Request(
            new Get(),
            toList([]),
            "",
            scheme,
            host,
            uri.port,
            uri.path,
            uri.query
          );
          return new Ok(req);
        }
      );
    }
  );
}
function set_body(req, body) {
  let method = req.method;
  let headers = req.headers;
  let scheme = req.scheme;
  let host = req.host;
  let port = req.port;
  let path = req.path;
  let query2 = req.query;
  return new Request(method, headers, body, scheme, host, port, path, query2);
}
function set_query(req, query2) {
  let pair = (t) => {
    return percent_encode(t[0]) + "=" + percent_encode(t[1]);
  };
  let query$1 = (() => {
    let _pipe = query2;
    let _pipe$1 = map(_pipe, pair);
    let _pipe$2 = intersperse(_pipe$1, "&");
    let _pipe$3 = concat2(_pipe$2);
    return new Some(_pipe$3);
  })();
  let _record = req;
  return new Request(
    _record.method,
    _record.headers,
    _record.body,
    _record.scheme,
    _record.host,
    _record.port,
    _record.path,
    query$1
  );
}
function set_method(req, method) {
  let _record = req;
  return new Request(
    method,
    _record.headers,
    _record.body,
    _record.scheme,
    _record.host,
    _record.port,
    _record.path,
    _record.query
  );
}
function to(url) {
  let _pipe = url;
  let _pipe$1 = parse(_pipe);
  return then$(_pipe$1, from_uri);
}
function set_path(req, path) {
  let _record = req;
  return new Request(
    _record.method,
    _record.headers,
    _record.body,
    _record.scheme,
    _record.host,
    _record.port,
    path,
    _record.query
  );
}

// build/dev/javascript/gleam_http/gleam/http/response.mjs
var Response = class extends CustomType {
  constructor(status, headers, body) {
    super();
    this.status = status;
    this.headers = headers;
    this.body = body;
  }
};

// build/dev/javascript/gleam_javascript/gleam_javascript_ffi.mjs
var PromiseLayer = class _PromiseLayer {
  constructor(promise) {
    this.promise = promise;
  }
  static wrap(value) {
    return value instanceof Promise ? new _PromiseLayer(value) : value;
  }
  static unwrap(value) {
    return value instanceof _PromiseLayer ? value.promise : value;
  }
};
function resolve(value) {
  return Promise.resolve(PromiseLayer.wrap(value));
}
function then_await(promise, fn) {
  return promise.then((value) => fn(PromiseLayer.unwrap(value)));
}
function map_promise(promise, fn) {
  return promise.then(
    (value) => PromiseLayer.wrap(fn(PromiseLayer.unwrap(value)))
  );
}

// build/dev/javascript/gleam_javascript/gleam/javascript/promise.mjs
function try_await(promise, callback) {
  let _pipe = promise;
  return then_await(
    _pipe,
    (result) => {
      if (result.isOk()) {
        let a = result[0];
        return callback(a);
      } else {
        let e = result[0];
        return resolve(new Error(e));
      }
    }
  );
}

// build/dev/javascript/gleam_fetch/gleam_fetch_ffi.mjs
async function raw_send(request) {
  try {
    return new Ok(await fetch(request));
  } catch (error2) {
    return new Error(new NetworkError(error2.toString()));
  }
}
function from_fetch_response(response) {
  return new Response(
    response.status,
    List.fromArray([...response.headers]),
    response
  );
}
function request_common(request) {
  let url = to_string4(to_uri(request));
  let method = method_to_string(request.method).toUpperCase();
  let options = {
    headers: make_headers(request.headers),
    method
  };
  return [url, options];
}
function to_fetch_request(request) {
  let [url, options] = request_common(request);
  if (options.method !== "GET" && options.method !== "HEAD")
    options.body = request.body;
  return new globalThis.Request(url, options);
}
function make_headers(headersList) {
  let headers = new globalThis.Headers();
  for (let [k, v] of headersList)
    headers.append(k.toLowerCase(), v);
  return headers;
}
async function read_json_body(response) {
  try {
    let body = await response.body.json();
    return new Ok(response.withFields({ body }));
  } catch (error2) {
    return new Error(new InvalidJsonBody());
  }
}

// build/dev/javascript/gleam_fetch/gleam/fetch.mjs
var NetworkError = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var InvalidJsonBody = class extends CustomType {
};
function send(request) {
  let _pipe = request;
  let _pipe$1 = to_fetch_request(_pipe);
  let _pipe$2 = raw_send(_pipe$1);
  return try_await(
    _pipe$2,
    (resp) => {
      return resolve(new Ok(from_fetch_response(resp)));
    }
  );
}

// build/dev/javascript/gleamrpc_http_client/gleamrpc/http/client.mjs
var IncorrectURIError = class extends CustomType {
  constructor(uri) {
    super();
    this.uri = uri;
  }
};
var ConnectionError = class extends CustomType {
  constructor(uri, reason) {
    super();
    this.uri = uri;
    this.reason = reason;
  }
};
var JsonDecodeError = class extends CustomType {
  constructor(error2) {
    super();
    this.error = error2;
  }
};
var InvalidJsonError = class extends CustomType {
};
var UnableToReadBodyError = class extends CustomType {
};
function fetch_to_gleamrpc_error(error2, uri) {
  if (error2 instanceof InvalidJsonBody) {
    return new InvalidJsonError();
  } else if (error2 instanceof NetworkError) {
    let reason = error2[0];
    return new ConnectionError(uri, reason);
  } else {
    return new UnableToReadBodyError();
  }
}
function handle_fetched_body(body_result, uri, procedure) {
  return try$(
    (() => {
      let _pipe = body_result;
      let _pipe$1 = map_error(
        _pipe,
        (_capture) => {
          return fetch_to_gleamrpc_error(_capture, uri);
        }
      );
      return map_error(
        _pipe$1,
        (var0) => {
          return new GleamRPCError(var0);
        }
      );
    })(),
    (res) => {
      let _pipe = res.body;
      let _pipe$1 = json_decode(procedure.return_type)(_pipe);
      let _pipe$2 = map_error(
        _pipe$1,
        (var0) => {
          return new UnexpectedFormat(var0);
        }
      );
      let _pipe$3 = map_error(
        _pipe$2,
        (var0) => {
          return new JsonDecodeError(var0);
        }
      );
      return map_error(
        _pipe$3,
        (var0) => {
          return new GleamRPCError(var0);
        }
      );
    }
  );
}
function router_paths(loop$router, loop$paths) {
  while (true) {
    let router = loop$router;
    let paths = loop$paths;
    if (router instanceof None) {
      return paths;
    } else {
      let router$1 = router[0];
      loop$router = router$1.parent;
      loop$paths = prepend(router$1.name, paths);
    }
  }
}
function generate_path(procedure) {
  return "/api/gleamRPC/" + (() => {
    let _pipe = router_paths(procedure.router, toList([]));
    let _pipe$1 = append(_pipe, toList([procedure.name]));
    return join(_pipe$1, "/");
  })();
}
function configure_query(req, procedure, params2) {
  let _pipe = req;
  let _pipe$1 = set_method(_pipe, new Get());
  let _pipe$2 = set_path(_pipe$1, generate_path(procedure));
  return set_query(
    _pipe$2,
    (() => {
      let _pipe$3 = params2;
      return encode2(_pipe$3, procedure.params_type);
    })()
  );
}
function configure_mutation(req, procedure, params2) {
  let _pipe = req;
  let _pipe$1 = set_method(_pipe, new Post());
  let _pipe$2 = set_path(_pipe$1, generate_path(procedure));
  return set_body(
    _pipe$2,
    (() => {
      let _pipe$3 = json_encode(params2, procedure.params_type);
      return to_string3(_pipe$3);
    })()
  );
}
function configure_request(req, procedure, params2) {
  let $ = procedure.type_;
  if ($ instanceof Query) {
    return configure_query(req, procedure, params2);
  } else {
    return configure_mutation(req, procedure, params2);
  }
}
function call2(uri) {
  let request = to(uri);
  if (!request.isOk()) {
    return (_, _1, callback) => {
      return callback(
        new Error(new GleamRPCError(new IncorrectURIError(uri)))
      );
    };
  } else {
    let req = request[0];
    return (proc, params2, callback) => {
      map_promise(
        (() => {
          let _pipe = req;
          let _pipe$1 = configure_request(_pipe, proc, params2);
          let _pipe$2 = send(_pipe$1);
          return try_await(_pipe$2, read_json_body);
        })(),
        (body_result) => {
          let _pipe = handle_fetched_body(body_result, uri, proc);
          return callback(_pipe);
        }
      );
      return void 0;
    };
  }
}
function http_client(uri) {
  return new ProcedureClient(call2(uri));
}

// build/dev/javascript/plinth/console_ffi.mjs
function error(value) {
  console.error(value);
}

// build/dev/javascript/client/client/utils.mjs
function client() {
  return http_client("http://localhost:8080");
}
function rpc_effect(client2, procedure, data, to_msg) {
  return from(
    (dispatch) => {
      let procedure_call = (() => {
        let _pipe = procedure;
        return with_client(_pipe, client2);
      })();
      return call(
        procedure_call,
        data,
        (result) => {
          if (!result.isOk()) {
            let err = result[0];
            return error(err);
          } else {
            let return$ = result[0];
            return dispatch(to_msg(return$));
          }
        }
      );
    }
  );
}

// build/dev/javascript/lustre/lustre/element/html.mjs
function text2(content) {
  return text(content);
}
function button(attrs, children2) {
  return element("button", attrs, children2);
}

// build/dev/javascript/lustre/lustre/event.mjs
function on2(name, handler) {
  return on(name, handler);
}

// build/dev/javascript/client/client/views/home.mjs
function view(model) {
  return button(
    toList([
      on2("click", (_) => {
        return new Ok(new Login("", ""));
      })
    ]),
    toList([text2("Login")])
  );
}

// build/dev/javascript/client/client.mjs
function init2(_) {
  return [new Model2(new None(), toList([])), none()];
}
function update(model, msg) {
  if (msg instanceof Login) {
    let pseudo = msg.username;
    let password = msg.password;
    return [
      model,
      rpc_effect(
        client(),
        login(),
        new LoginData(pseudo, password),
        (var0) => {
          return new SetUser(var0);
        }
      )
    ];
  } else {
    let user = msg.user;
    return [
      (() => {
        let _record = model;
        return new Model2(new Some(user), _record.qwizes);
      })(),
      none()
    ];
  }
}
function view2(model) {
  return view(model);
}
function main() {
  let app = application(init2, update, view2);
  let $ = start2(app, "#app", void 0);
  if (!$.isOk()) {
    throw makeError(
      "let_assert",
      "client",
      13,
      "main",
      "Pattern match failed, no pattern matched the value.",
      { value: $ }
    );
  }
  return void 0;
}

// build/.lustre/entry.mjs
main();

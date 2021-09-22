/**
 * Shim crypto methods that are required for ethers to work.
 * These methods are not provided in flutter_js package.
 */
 window.crypto = window.crypto || {};

 /**
  * Implements a shim for `getRandomValues`
  * 
  * @see https://developer.mozilla.org/en-US/docs/Web/API/Crypto/getRandomValues
  * 
  * @param {*} typedArray A preallocated array to fill in random bytes into
  * @returns The provided array
  */
 window.crypto.getRandomValues = (typedArray) => {
     for (let index in typedArray) {
         typedArray[index] = Math.round(Math.random() * 255);
     }
     return typedArray;
 };
 
 /**
  * Implements a shim for `randomBytes`
  * 
  * @see https://nodejs.org/api/crypto.html#crypto_crypto_randombytes_size_callback
  * 
  * @param {*} size Number of random bytes to generate
  * @param {*} callback Callback method providing error and random buffer
  * @returns Buffer of random bytes
  */
 window.crypto.randomBytes = (size, callback) => {
     const QUOTA = 65536;
     const arr = new Uint8Array(size);
     for (var i = 0; i < size; i += QUOTA) {
         window.crypto.getRandomValues(arr.subarray(i, i + Math.min(size - i, QUOTA)));
     }
     const buf = Buffer.from(arr);
     if (!!callback) {
         callback(null, buf);
     }
     return buf;
 }
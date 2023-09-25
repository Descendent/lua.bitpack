# API Reference

### Buffer

#### Constructors

##### Buffer New()
##### Buffer New(string str)
Creates and returns a new `Buffer` instance. If `str` is given, it will be treated as a binary string, and deserialized into the `Buffer` instance's data.

#### Static Methods

##### nil ConfigureDebug(boolean value)
If `value` is false, most assertions in methods will be skipped; otherwise, all assertions will be checked. By default, all assertions will be checked. Skipping assertions will slightly increase performance, but will also make the cause of errors more difficult to pinpoint.

##### integer, integer Normalize(integer octet, integer bitBegin)
Returns new values for `octet` and `bitBegin`, where `bitBegin` greater than 8 (or less than 1) is rolled over to increase (or decrease) `octet`.

##### integer, integer Increment(integer octet, integer bitBegin, integer bitCount)
Returns new values for `octet` and `bitBegin`, where `bitBegin` is increased by `bitCount`, then normalized.

#### Methods

##### boolean CanHas(integer octet)
##### boolean CanHas(integer octet, integer bitBegin, integer bitCount)
Returns `true` if this `Buffer` instance's length is enough to read/write `bitCount` bits, starting from bit `bitBegin` within octet `octet`; otherwise, returns `false`. If `bitBegin` and `bitCount` aren't given, `bitBegin` will be 1, and `bitCount` will be 8.

##### integer Get(integer octet)
##### integer Get(integer octet, integer bitBegin, integer bitCount)
Returns the value from reading `bitCount` bits, starting from bit `bitBegin` within octet `octet`, as an unsigned integer. If `bitBegin` and `bitCount` aren't given, `bitBegin` will be 1, and `bitCount` will be 8. `bitCount` must be less than or equal to 32.

##### nil Set(integer octet, integer value)
##### nil Set(integer octet, integer bitBegin, integer bitCount, integer value)
Writes value into `bitCount` bits, starting from bit `bitBegin` within octet `octet`. If `bitBegin` and `bitCount` aren't given, `bitBegin` will be 1, and `bitCount` will be 8. `bitCount` must be less than or equal to 32. `value` must be an unsigned integer less than 2<sup>`bitCount`</sup>.

##### nil Reserve(integer octet)
##### nil Reserve(integer octet, integer bitBegin, integer bitCount)
Changes the length of this `Buffer` instance to `octet` octets, plus the minimum additional octets necessary to contain `bitCount` bits, starting from bit `bitBegin` within octet `octet`. If the new length in bits is less than the old length in bits, excess trailing data will be erased. If `bitBegin` and `bitCount` aren't given, `bitBegin` will be 1, and `bitCount` will be 8.

#### Metamethods

##### integer __len()
Returns the length of this `Buffer` instance, in octets (bytes).

##### string __tostring()
Returns a binary string serialized from this `Buffer` instance's data.

### BufferReader

#### Constructors

##### BufferReader New(Buffer buf)
##### BufferReader New(Buffer buf, integer octet)
##### BufferReader New(Buffer buf, integer octet, integer bitBegin)
Creates and returns a new `BufferReader` instance for `buf`, with its position at bit `bitBegin` within octet `octet`. If `octet` and `bitBegin` aren't given, `octet` and `bitBegin` will each be 1. If `bitBegin` isn't given, it will be 1.

#### Methods (Accessors)

##### integer, integer GetCurrent()
Returns this `BufferReader` instance's current position as: octet, and bit within that octet.

##### nil SetCurrent(integer octet, integer bitBegin)
Changes this `BufferReader` instance's current position to bit `bitBegin` within octet `octet`. If `bitBegin` isn't given, it will be 1.

#### Methods

##### boolean CanHas(integer bitCount)
Returns `true` if the length of this `BufferReader` instance's `Buffer` is enough to read/write `bitCount` bits, starting from this `BufferReader` instance's position; otherwise, returns `false`.

##### integer Get(integer bitCount)
Returns the value from reading `bitCount` bits, starting from this `BufferReader` instance's position, as an unsigned integer. Increments this `BufferReader` instance's position by `bitCount` bits after reading. `bitCount` must be less than or equal to 32.

##### integer GetSignify(integer bitCount)
Returns the value from reading `bitCount` bits, starting from this `BufferReader` instance's position, as a signed integer. Increments this `BufferReader` instance's position by `bitCount` bits after reading. `bitCount` must be less than or equal to 32.

##### integer GetNillify(integer bitCount)
##### nil GetNillify(integer bitCount)
Returns the value from reading `bitCount` bits, starting from this `BufferReader` instance's position, as nil or an unsigned integer. If the value is 0, returns `nil`; otherwise, returns the value. Increments this `BufferReader` instance's position by `bitCount` bits after reading. `bitCount` must be less than or equal to 32.

##### boolean GetBoolify(integer bitCount)
Returns the value from reading `bitCount` bits, starting from this `BufferReader` instance's position, as a Boolean value. If the value is 0, returns `false`; otherwise, returns `true`. Increments this `BufferReader` instance's position by `bitCount` bits after reading. `bitCount` must be less than or equal to 32.

### BufferWriter

#### Constructors

##### BufferWriter New(Buffer buf)
##### BufferWriter New(Buffer buf, integer octet)
##### BufferWriter New(Buffer buf, integer octet, integer bitBegin)
Creates and returns a new `BufferWriter` instance for `buf`, with its position at bit `bitBegin` within octet `octet`. If `octet` and `bitBegin` aren't given, `octet` and `bitBegin` will each be 1. If `bitBegin` isn't given, it will be 1.

#### Methods (Accessors)

##### integer, integer GetCurrent()
Returns this `BufferWriter` instance's current position as: octet, and bit within that octet.

##### nil SetCurrent(integer octet, integer bitBegin)
Changes this `BufferWriter` instance's current position to bit `bitBegin` within octet `octet`. If `bitBegin` isn't given, it will be 1.

#### Methods

##### boolean CanHas(integer bitCount)
Returns `true` if the length of this `BufferWriter` instance's `Buffer` is enough to read/write `bitCount` bits, starting from this `BufferWriter` instance's position; otherwise, returns `false`.

##### nil Set(integer bitCount, integer value)
##### nil Set(integer bitCount, integer value, boolean reserve)
Writes `value` into `bitCount` bits, starting from this `BufferWriter` instance's position, as an unsigned integer. Increments this `BufferWriter` instance's position by `bitCount` bits after writing. If `reserve` is `true`, this `BufferWriter` instance's `Reserve` method will be called before writing, to ensure the `Buffer` has sufficient length. `bitCount` must be less than or equal to 32. `value` must be an unsigned integer less than 2<sup>`bitCount`</sup>.

##### nil SetSignify(integer bitCount, integer value)
##### nil SetSignify(integer bitCount, integer value, boolean reserve)
Writes `value` into `bitCount` bits, starting from this `BufferWriter` instance's position, as a signed integer. Increments this `BufferWriter` instance's position by `bitCount` bits after writing. If `reserve` is `true`, this `BufferWriter` instance's `Reserve` method will be called before writing, to ensure the `Buffer` has sufficient length. `bitCount` must be less than or equal to 32. `value` must be a signed integer greater than or equal to −2<sup>(`bitCount` − 1)</sup>, and less than 2<sup>(`bitCount` − 1)</sup>.

##### nil SetNillify(integer bitCount, integer value)
##### nil SetNillify(integer bitCount, nil value)
##### nil SetNillify(integer bitCount, integer value, boolean reserve)
##### nil SetNillify(integer bitCount, nil value, boolean reserve)
Writes `value` into `bitCount` bits, starting from this `BufferWriter` instance's position, as `nil` or an unsigned integer. If `value` is `nil`, writes 0; otherwise, writes value. Increments this `BufferWriter` instance's position by `bitCount` bits after writing. If `reserve` is `true`, this `BufferWriter` instance's `Reserve` method will be called before writing, to ensure the `Buffer` has sufficient length. `bitCount` must be less than or equal to 32. `value` must be `nil`, or an unsigned integer less than 2<sup>`bitCount`</sup>.

##### nil SetBoolify(integer bitCount, boolean value)
##### nil SetBoolify(integer bitCount, boolean value, boolean reserve)
Writes `value` into `bitCount` bits, starting from this `BufferWriter` instance's position, as a Boolean value. If `value` is `false`, writes 0; otherwise, writes 1. Increments this `BufferWriter` instance's position by `bitCount` bits after writing. If `reserve` is `true`, this `BufferWriter` instance's `Reserve` method will be called before writing, to ensure the `Buffer` has sufficient length. `bitCount` must be less than or equal to 32.

##### nil Reserve(integer bitCount)
Increases the length of this `BufferWriter` instance's `Buffer` by the minimum octets necessary to contain an additional `bitCount` bits, starting from this `BufferWriter` instance's position.

## Z85

### Z85BufferDecode

#### Constructors

##### Z85BufferDecode New(Buffer buf, string str)
Creates and returns a new `Z85BufferDecode` instance for decoding `str` into `buf`.

#### Methods (Accessors)

##### Buffer GetBuffer()

Returns this `Z85BufferDecode` instance's decoded `Buffer` instance.

##### string GetString()
Returns this `Z85BufferDecode` instance's encoded binary string.

##### integer GetRemaining()
Returns the amount of octets remaining to be decoded.

#### Methods

##### nil Process(integer count)
Decodes the next `count` octets from this `Z85BufferDecode` instance's encoded binary string, into this `Z85BufferDecode` instance's decoded `Buffer` instance. If the remaining amount of octets is less than `count`, or less than 5, the remaining amount of octets will be decoded; otherwise, the minimum amount of 5-octet chunks totaling at least `count` octets will be decoded.

### Z85BufferEncode

#### Constructors

##### Z85BufferEncode New(Buffer buf)
##### Z85BufferEncode New(Buffer buf, table str)
Creates and returns a new `Z85BufferEncode` instance for encoding `buf` into `str`. If `str` is given, values associated with its integer indices will be overwritten.

#### Methods (Accessors)

##### Buffer GetBuffer()
Returns this `Z85BufferEncode` instance's decoded `Buffer` instance.

##### string GetString()
Returns this Z85BufferEncode instance's encoded binary string.

##### integer GetRemaining()
Returns the amount of octets remaining to be encoded.

#### Methods

##### nil Process(integer count)
Encodes the next `count` octets from this `Z85BufferEncode` instance's decoded `Buffer` instance, into this `Z85BufferEncode` instance's encoded binary string. If the remaining amount of octets is less than `count`, or less than 4, the remaining amount of octets will be encoded; otherwise, the minimum amount of 4-octet chunks totaling at least `count` octets will be encoded.

# Examples

## Usage

### Example.lua

```lua
local Buffer = require("Buffer")
local BufferWriter = require("BufferWriter")
local BufferReader = require("BufferReader")
local Z85BufferEncode = require("Z85BufferEncode")
local Z85BufferDecode = require("Z85BufferDecode")

local _a = Buffer.New()
local _writer = BufferWriter.New(_a)

_writer:Reserve(64)
_writer:Set(8, 0x86)
_writer:Set(8, 0x4f)
_writer:Set(8, 0xd2)
_writer:Set(8, 0x6f)
_writer:Set(8, 0xb5)
_writer:Set(8, 0x59)
_writer:Set(8, 0xf7)
_writer:Set(8, 0x5b)

local _encode = Z85BufferEncode.New(_a)

while _encode:GetRemaining() > 0 do
    _encode:Process(4)
end

local _str = _encode:GetString()

print(_str)

local _b = Buffer.New()
local _decode = Z85BufferDecode.New(_b, _str)

while _decode:GetRemaining() > 0 do
    _decode:Process(5)
end

local _reader = BufferReader.New(_b)

local _hex = {}
_hex[1] = string.format("%x", _reader:Get(8))
_hex[2] = string.format("%x", _reader:Get(8))
_hex[3] = string.format("%x", _reader:Get(8))
_hex[4] = string.format("%x", _reader:Get(8))
_hex[5] = string.format("%x", _reader:Get(8))
_hex[6] = string.format("%x", _reader:Get(8))
_hex[7] = string.format("%x", _reader:Get(8))
_hex[8] = string.format("%x", _reader:Get(8))

print(table.concat(_hex, " "))
```

### 🧾 (Output)

```text
HelloWorld
86 4f d2 6f b5 59 f7 5b
```

//
//  MurmurHash3
//


// 中文
//
// 類型：雜湊計算
// 編寫：Wei-Lun Huang
// 參考：https://en.wikipedia.org/wiki/MurmurHash
//       https://github.com/aappleby/smhasher/blob/master/src/MurmurHash3.cpp
// 說明：MurmurHash3 計算
//
// 作用：
// 1. MurmurHash3_32bit_x86, MurmurHash3_128bit_x86, MurmurHash3_128bit_x64，
//    適用於連續資料源計算，速度較快些。
// 2. TMurmurHash3_32bit_x86, TMurmurHash3_128bit_x86, TMurmurHash3_128bit_x64，
//    適用於大型資料的分段計算，速度會稍微慢一點點。
// 3. UInt128
//    為緊湊式結構，有 UInt64 * 2, Cardinal* 4, Word * 8, Byte * 16 等型別共用空間
// 4. Int128ToHex_x86, Int128ToHex_x64
//    將 UInt128 轉換數值為相應的 16 進位字串，
//    * 由於 MurmurHash3 16 進位字串顯示通常是以運算單位的 Little-Endian 方式顯示，
//      因此 128bit x86 的顯示方式為 4 個 4Byte 整數以 Little-Endian 轉為 16 進位字串，
//      # 比如陣列：01020304 05060708 090A0B0C 0D0E0F10
//        轉字串為 '04030201 08070605 0C0B0A09 100F0E0D'
//      而 128bit x64 的顯示方式為 2 個 8Byte 整數以 Little-Endian 轉為 16 進位字串，
//      # 比如陣列：0102030405060708 090A0B0C0D0E0F10
//        轉字串為 '0807060504030201 100F0E0D0C0B0A09'
//
// 歷程：
//   2025年11月16日 建立，與發佈後的註解修正
//   2025年11月17日 改進組合語言演算性能，與去除多餘的編譯指示設定
//   2025年11月18日 微調組合語言指令
//   2026年01月24日 改進 MurmurHash3_32bit_x86 未滿一個區塊的剩餘資料處理，
//                  完全精確存取指定位址Byte，以排除可能發生的存取越界問題。
//   2026年02月02日
//     修正 GetDataBlockFlowing32bit 與 GetDataBlockFlowing128bit 可能發生的記憶體存取超出範圍。
//     修正 MurmurHash3_32bit_x86 Pascal 程式碼區塊的尾端資料處理錯誤。
//     改進去除多餘的函數呼叫。
//     改正註解。
//
// 其他：<無>
//
// 最後變更日期：2026年02月02日
//


// English
//
// Type: Hash Calculation / Hashing Algorithm
// Author: Wei-Lun Huang
// Reference:
//   https://en.wikipedia.org/wiki/MurmurHash
//   https://github.com/aappleby/smhasher/blob/master/src/MurmurHash3.cpp
// Description: MurmurHash3 calculation
//
// Features:
// 1. MurmurHash3_32bit_x86, MurmurHash3_128bit_x86, MurmurHash3_128bit_x64,
//    Are suitable for calculations on continuous data sources and are faster.
// 2. TMurmurHash3_32bit_x86, TMurmurHash3_128bit_x86, TMurmurHash3_128bit_x64,
//    Are suitable for segmented calculation of large data; the speed is slightly slower.
// 3. UInt128
//    Is a compact structure, sharing space with types such as
//    UInt64 * 2, Cardinal * 4, Word * 8, and Byte * 16.
// 4. Int128ToHex_x86, Int128ToHex_x64
//    Converts the UInt128 value to the corresponding hexadecimal string.
//    * Since the hexadecimal string display for MurmurHash3 usually follows the
//      Little-Endian manner of the operational unit, Therefore...
//      The display method for 128bit x86 converts four 4byte integers
//      into a hexadecimal string using Little-Endian,
//      # For example, the array:  01020304 05060708 090A0B0C 0D0E0F10
//        Converts to the string: '04030201 08070605 0C0B0A09 100F0E0D'
//      The display method for 128bit x64 converts two 8byte integers
//      into a hexadecimal string using Little-Endian,
//      # For example, the array:  0102030405060708 090A0B0C0D0E0F10
//        Converts to the string: '0807060504030201 100F0E0D0C0B0A09'
//
// History:
//   Nov 16, 2025 Created and post-release annotation corrections.
//   Nov 17, 2025
//     Assembly code performance improvement.
//     Removal of superfluous compiler directive settings.
//   Nov 18, 2025
//     Minor adjustment of assembly language instructions to align some assembly binary code.
//   Jan 24, 2026
//     Enhanced the processing of incomplete blocks in MurmurHash3_x86_32 by ensuring
//     only valid bytes are accessed, effectively preventing buffer overreads.
//   Feb 02, 2026
//     Fixed a potential memory access out-of-range error in GetDataBlockFlowing32bit and
//     GetDataBlockFlowing128bit.
//     Fixed the end-of-line data handling of the MurmurHash3_32bit_x86 Pascal code.
//     Improved functionality by removing redundant function calls.
//     Corrected annotations.
//
// Others: <None>
//
// Last modified date: Feb 02, 2026
//


// 下面註解為 wiki 上的 MurmurHash3 32bit 演算法 = = = = = = = = = =
// The following comments describe the MurmurHash3 32-bit algorithm from the wiki = = =
//
// Algorithm
//
//algorithm Murmur3_32 is
//  Note: In this version, all arithmetic is performed with unsigned 32-bit integers.
//        In the case of overflow, the result is reduced modulo 232.
//  input: key, len, seed
//
//  c1 ← 0xcc9e2d51
//  c2 ← 0x1b873593
//  r1 ← 15
//  r2 ← 13
//  m ← 5
//  n ← 0xe6546b64
//
//  hash ← seed
//
//  for each fourByteChunk of key do
//      k ← fourByteChunk
//
//      k ← k × c1
//      k ← k ROL r1
//      k ← k × c2
//
//      hash ← hash XOR k
//      hash ← hash ROL r2
//      hash ← (hash × m) + n
//
//  with any remainingBytesInKey do
//      remainingBytes ← SwapToLittleEndian(remainingBytesInKey)
//      // Note: Endian swapping is only necessary on big-endian machines.
//      //       The purpose is to place the meaningful digits towards the low end of the value,
//      //       so that these digits have the greatest potential to affect the low range digits
//      //       in the subsequent multiplication.  Consider that locating the meaningful digits
//      //       in the high range would produce a greater effect upon the high digits of the
//      //       multiplication, and notably, that such high digits are likely to be discarded
//      //       by the modulo arithmetic under overflow.  We don't want that.
//
//      remainingBytes ← remainingBytes × c1
//      remainingBytes ← remainingBytes ROL r1
//      remainingBytes ← remainingBytes × c2
//
//      hash ← hash XOR remainingBytes
//
//  hash ← hash XOR len
//
//  hash ← hash XOR (hash >> 16)
//  hash ← hash × 0x85ebca6b
//  hash ← hash XOR (hash >> 13)
//  hash ← hash × 0xc2b2ae35
//  hash ← hash XOR (hash >> 16)
//
// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
//
// C
//
//static inline uint32_t murmur_32_scramble(uint32_t k) {
//  k *= 0xcc9e2d51;
//  k = (k << 15) | (k >> 17);
//  k *= 0x1b873593;
//  return k;
//}
//uint32_t murmur3_32(const uint8_t* key, size_t len, uint32_t seed) {
//	uint32_t h = seed;
//  uint32_t k;
//  /* Read in groups of 4. */
//  for (size_t i = len >> 2; i; i--) {
//    memcpy(&k, key, sizeof(uint32_t));
//    key += sizeof(uint32_t);
//    h ^= murmur_32_scramble(k);
//    h = (h << 13) | (h >> 19);
//    h = h * 5 + 0xe6546b64;
//  }
//  /* Read the rest. */
//  k = 0;
//  for (size_t i = len & 3; i; i--) {
//    k <<= 8;
//    k |= key[i - 1];
//  }
//  h ^= murmur_32_scramble(k); // *這裡有點問題 *There is a slight issue here
//  // 雖然上面迴圈在 len = 0 時沒執行，但 h 仍然被 xor 0，
//  // 多這一步導致計算結果與標準計算值不相同，
//  // 細解：
//  //   因 k = 0 而 len = 0 跳過迴圈，然後卻 h ^= murmur_32_scramble(k)，
//  //   導致 h ^= 0
//  // 但如果不追求與一般網路上找到的 MurmurHash3 計算器結果一致則不須在意。
//
//  // Although the loop above is not executed when len = 0, h is still XORed with 0.
//  // This extra step causes the calculation result to differ from the
//  // standard calculated value.
//  // Detailed explanation: Since k = 0 and len = 0, the loop is skipped,
//  // but then h ^= murmur_32_scramble(k) is performed, which results in h ^= 0.
//  // However, if consistency with the results from standard MurmurHash3
//  // calculators online is not required, this can be ignored.
//
//  /* Finalize. */
//	h ^= len;
//	h ^= h >> 16;
//	h *= 0x85ebca6b;
//	h ^= h >> 13;
//	h *= 0xc2b2ae35;
//	h ^= h >> 16;
//	return h;
//}

//
// 在 Big-endian 處理器中資料由記憶體載入至處理器中需要做位元組交換，
// 但在一般電腦處理器(為 Little-Endian)中則不需要，
//
// In Big-endian processors, byte swapping is required when data is loaded from
// memory into the processor, but it is not needed in general computer processors
// (which are Little-Endian).
//

unit MurmurHash3;

interface

uses
  System.SysUtils, System.Classes, System.Hash;

{$R-,Q-,B-}  // RangeChecks, OverFlowChecks, BoolEval
{$O+}        // Optimization
{$INLINE ON} // ON|OFF|AUTO

//
// 這是針對 MurmurHash3_32bit_x86 在 X86 與 X64 編譯下指定使用部分組合語言，
// 可以增加運算效率。如需停用，請在 '{' 後加上 '.'，如：'{.$DEFINE UseASM}'
//
// This specifies the use of partial assembly language for MurmurHash3_32bit_x86
// when compiling under X86 and X64, which can increase computational efficiency.
// To disable, please add a '.' after '{', such as: '{.$DEFINE UseASM}'
//
{$DEFINE UseASM}

type
  UInt128 = packed record
    function ToString: string;
    function ToStringX86: string;
    function ToStringX64: string;
    case Integer of
      0: (u64: packed array[0.. 1] of UInt64;   );
      1: (u32: packed array[0.. 3] of Cardinal; );
      2: (u16: packed array[0.. 7] of Word;     );
      3: (u8 : packed array[0..15] of Byte;     );
  end;
  PUInt128 = ^UInt128;


  TMurmurHash3_32bit_x86 = record
  private const
    // 區塊(BlockSize)大小 與 雜湊(HashSize)大小 均為 4byte = SizeOf(Cardinal)
    BlockSize = 4; // SizeOf(Cardinal)
    HashSize  = 4; // SizeOf(Cardinal)

    // 位元往左循環位移量
    R1 = 15;
    R2 = 13;

    // 固定的乘量值
    C1 = $cc9e2d51;
    C2 = $1b873593;
    M  = 5;

    // 固定的增量值
    N  = $e6546b64;
  private
    FHashContext: Cardinal;     // 雜湊 (計算中 或 已完成計算)
    FLength: Cardinal;          // 已輸入的資料量
    FSeed: Cardinal;            // 種子值
    FRemainingData: Cardinal;   // 待處理的資料的衝區
    FRemainingLength: Cardinal; // 待處理的資料的長度
    FFinalized: Boolean;        // 是否已作結尾計算，因已做結尾運算則不應再次接續運算。

    procedure Scramble(var K: Cardinal); inline;
    procedure Compress(var H: Cardinal; K: Cardinal); inline;
    procedure ClearRemainingBuffer; inline;
    procedure Initialize(ASeed: Cardinal); overload; inline;
    procedure Initialize; overload; inline;
    procedure Finalize; ///inline;
    procedure DoDigest; inline;
    function GetDigest: TBytes;
  public
    class function Create: TMurmurHash3_32bit_x86; overload; static; inline;
    class function Create(ASeed: Cardinal): TMurmurHash3_32bit_x86; overload; static; inline;

    procedure Reset;
    procedure Update(const AData; ALength: Cardinal); overload;
    procedure Update(const AData: TBytes; ALength: Cardinal = 0); overload; inline;
    procedure Update(const Input: string); overload; inline;

    function GetBlockSize: Integer; inline;
    function GetHashSize: Integer; inline;
    function HashAsBytes: TBytes; inline;
    function HashAsCardinal: Cardinal; inline;
    function HashAsString: string; inline;


    class function GetHashBytes(const AData: string): TBytes; overload; static;
    class function GetHashString(const AString: string): string; overload; static; inline;

    class function GetHashBytes(const AStream: TStream): TBytes; overload; static;
    class function GetHashString(const AStream: TStream): string; overload; static; inline;

    class function GetHashBytesFromFile(const AFileName: TFileName): TBytes; static;
    class function GetHashStringFromFile(const AFileName: TFileName): string; static; inline;

    class function GetHMAC(const AData, AKey: string): string; static; inline;
    class function GetHMACAsBytes(const AData, AKey: string): TBytes; overload; static;
    class function GetHMACAsBytes(const AData: string; const AKey: TBytes): TBytes; overload; static;
    class function GetHMACAsBytes(const AData: TBytes; const AKey: string): TBytes; overload; static;
    class function GetHMACAsBytes(const AData, AKey: TBytes): TBytes; overload; static;
  end;


  TMurmurHash3_128bit_x86 = record
  private const
    // 區塊(BlockSize)大小 與 雜湊(HashSize)大小 均為 16byte = SizeOf(UInt128)
    BlockSize = 4 * 4; // SizeOf(Cardinal) * 4 = SizeOf(UInt128)
    HashSize  = 4 * 4; // SizeOf(Cardinal) * 4 = SizeOf(UInt128)
    // 一個 x86 計算組成處理的料量為 4Byte(32bit) 的正整數值(C 為 int，Delphi 為 Cardinal)
    // 因此 128bit_x86 的計算分為四組

    // 位元往左循環位移量
    R1A = 15; R1B = 19; // 第一計算組
    R2A = 16; R2B = 17; // 第二計算組
    R3A = 17; R3B = 15; // 第三計算組
    R4A = 18; R4B = 13; // 第四計算組
    // 固定增量值
    C1  = $239b961b;    // 第一計算組
    C2  = $ab0e9789;    // 第二計算組
    C3  = $38b34ae5;    // 第三計算組
    C4  = $a1e38b93;    // 第四計算組
    // 固定的乘量值
    N1  = $561ccd1b;    // 第一計算組
    N2  = $0bcaa747;    // 第二計算組
    N3  = $96cd1c35;    // 第三計算組
    N4  = $32ac3b17;    // 第四計算組
    M   = 5;
  private
    FHashContext: UInt128;      // 雜湊 (計算中 或 已完成計算)
    FLength: Cardinal;          // 已輸入的資料量
    FSeed: Cardinal;            // 種子值
    FRemainingData: UInt128;    // 待處理的資料的衝區
    FRemainingLength: Cardinal; // 待處理的資料的長度
    FFinalized: Boolean;        // 是否已作結尾計算，因已做結尾運算則不應再次接續運算。

    procedure Scramble1(var K: Cardinal); inline;
    procedure Scramble2(var K: Cardinal); inline;
    procedure Scramble3(var K: Cardinal); inline;
    procedure Scramble4(var K: Cardinal); inline;
    procedure Scramble(var K: UInt128); inline;
    procedure Compress1(var HA: Cardinal; HB, K: Cardinal); inline;
    procedure Compress2(var HA: Cardinal; HB, K: Cardinal); inline;
    procedure Compress3(var HA: Cardinal; HB, K: Cardinal); inline;
    procedure Compress4(var HA: Cardinal; HB, K: Cardinal); inline;
    procedure Compress(var H: UInt128; const K: UInt128); inline;

    procedure ClearRemainingBuffer; inline;
    procedure Initialize(ASeed: Cardinal); overload;
    procedure Initialize; overload;
    procedure Finalize;
    procedure DoDigest; inline;
    function GetDigest: TBytes;
  public
    class function Create: TMurmurHash3_128bit_x86; overload; static; inline;
    class function Create(ASeed: Cardinal): TMurmurHash3_128bit_x86; overload; static; inline;

    procedure Reset;
    procedure Update(const AData; ALength: Cardinal); overload;
    procedure Update(const AData: TBytes; ALength: Cardinal = 0); overload; inline;
    procedure Update(const Input: string); overload; inline;

    function GetBlockSize: Integer; inline;
    function GetHashSize: Integer; inline;
    function HashAsBytes: TBytes; inline;
    function HashAsUInt128: UInt128; inline;
    function HashAsString: string; inline;

    class function GetHashBytes(const AData: string): TBytes; overload; static;
    class function GetHashString(const AString: string): string; overload; static; inline;

    class function GetHashBytes(const AStream: TStream): TBytes; overload; static;
    class function GetHashString(const AStream: TStream): string; overload; static; inline;

    class function GetHashBytesFromFile(const AFileName: TFileName): TBytes; static;
    class function GetHashStringFromFile(const AFileName: TFileName): string; static; inline;

    class function GetHMAC(const AData, AKey: string): string; static; inline;
    class function GetHMACAsBytes(const AData, AKey: string): TBytes; overload; static;
    class function GetHMACAsBytes(const AData: string; const AKey: TBytes): TBytes; overload; static;
    class function GetHMACAsBytes(const AData: TBytes; const AKey: string): TBytes; overload; static;
    class function GetHMACAsBytes(const AData, AKey: TBytes): TBytes; overload; static;
  end;


  TMurmurHash3_128bit_x64 = record
  private const
    // 區塊(BlockSize)大小 與 雜湊(HashSize)大小 均為 16byte = SizeOf(UInt128)
    BlockSize = 8 * 2; // SizeOf(UInt64) * 2 = SizeOf(UInt128)
    HashSize  = 8 * 2; // SizeOf(UInt64) * 2 = SizeOf(UInt128)
    // 一個 x64 計算組成處理的料量為 8Byte(64bit) 的正整數值
    // 因此 128bit_x64 的計算分為兩組

    // 位元往左循環位移量
    R1A = 31; R1B = 27;              // 第一計算組
    R2A = 33; R2B = 31;              // 第二計算組
    // 固定增量值
    C1  = UInt64($87c37b91114253d5); // 第一計算組
    C2  = UInt64($4cf5ad432745937f); // 第二計算組
    // 固定的乘量值
    N1  = $52dce729;                 // 第一計算組
    N2  = $38495ab5;                 // 第二計算組
    M   = 5;
  private
    FHashContext: UInt128;      // 雜湊 (計算中 或 已完成計算)
    FLength: Cardinal;          // 已輸入的資料量
    FSeed: Cardinal;            // 種子值
    FRemainingData: UInt128;    // 待處理的資料的衝區
    FRemainingLength: Cardinal; // 待處理的資料的長度
    FFinalized: Boolean;        // 是否已作結尾計算，因已做結尾運算則不應再次接續運算。

    procedure Scramble1(var K: UInt64); inline;
    procedure Scramble2(var K: UInt64); inline;
    procedure Scramble(var K: UInt128); inline;
    procedure Compress1(var HA: UInt64; HB, K: UInt64); inline;
    procedure Compress2(var HA: UInt64; HB, K: UInt64); inline;
    procedure Compress(var H: UInt128; const K: UInt128); inline;

    procedure ClearRemainingBuffer; inline;
    procedure Initialize(ASeed: Cardinal); overload;
    procedure Initialize; overload;
    procedure Finalize;
    procedure DoDigest; inline;
    function GetDigest: TBytes;
  public
    class function Create: TMurmurHash3_128bit_x64; overload; static; inline;
    class function Create(ASeed: Cardinal): TMurmurHash3_128bit_x64; overload; static; inline;

    procedure Reset;
    procedure Update(const AData; ALength: Cardinal); overload;
    procedure Update(const AData: TBytes; ALength: Cardinal = 0); overload; inline;
    procedure Update(const Input: string); overload; inline;

    function GetBlockSize: Integer; inline;
    function GetHashSize: Integer; inline;
    function HashAsBytes: TBytes; inline;
    function HashAsUInt128: UInt128; inline;
    function HashAsString: string; inline;

    class function GetHashBytes(const AData: string): TBytes; overload; static;
    class function GetHashString(const AString: string): string; overload; static; inline;

    class function GetHashBytes(const AStream: TStream): TBytes; overload; static;
    class function GetHashString(const AStream: TStream): string; overload; static; inline;

    class function GetHashBytesFromFile(const AFileName: TFileName): TBytes; static;
    class function GetHashStringFromFile(const AFileName: TFileName): string; static; inline;

    class function GetHMAC(const AData, AKey: string): string; static; inline;
    class function GetHMACAsBytes(const AData, AKey: string): TBytes; overload; static;
    class function GetHMACAsBytes(const AData: string; const AKey: TBytes): TBytes; overload; static;
    class function GetHMACAsBytes(const AData: TBytes; const AKey: string): TBytes; overload; static;
    class function GetHMACAsBytes(const AData, AKey: TBytes): TBytes; overload; static;
  end;

// 直接以指定緩衝區代替 Delphi 原 IntToHex 函數的 string 記憶體分配。
//
// Directly uses the specified buffer instead of the string memory allocation in the original Delphi IntToHex function.
function IntToHex(strBuff: PChar; BuffLen: Integer; Value: Cardinal; MinDigits: Integer): Boolean; overload;
function IntToHex(strBuff: PChar; BuffLen: Integer; Value: UInt64; MinDigits: Integer): Boolean; overload;

// 一次性分配足夠的 string 長度並以 32bit 長度轉換數值為 16 進位字串。
//
// Allocate sufficient string length once and convert the value to a hexadecimal
// string using 32-bit length.
function Int128ToHex_x86(const Value: UInt128): string;

// 一次性分配足夠的 string 長度並以 64bit 長度轉換數值為 16 進位字串。
//
// Allocate sufficient string length once and convert the value to a hexadecimal
// string using 64-bit length.
function Int128ToHex_x64(const Value: UInt128): string;

// 用於連續資料源，去除不需要的分段合併，因此可以較快速的計算完成
//
// Used for continuous data sources, removing unnecessary segmentation and merging,
// thus allowing for faster calculation completion.
function MurmurHash3_32bit_x86(const Data; Len: Cardinal; Seed: Cardinal): Cardinal;
function MurmurHash3_128bit_x86(const Data; Len: Cardinal; Seed: Cardinal): UInt128;
function MurmurHash3_128bit_x64(const Data; Len: Cardinal; Seed: Cardinal): UInt128;

implementation

//uses
//  Debug;

resourcestring
  errCanNotUpdate = 'MurmurHash: Cannot update a finalized hash';


function Offset(p: Pointer; Amount: Integer): Pointer; inline;
begin
  Result := Pointer(NativeInt(p) + Amount);
end;

const
  HexChar: array[0..15] of Char = '0123456789ABCDEF';

function IntToHex(strBuff: PChar; BuffLen: Integer; Value: Cardinal; MinDigits: Integer): Boolean;
var
  N: Cardinal;
  C, I: Integer;
  p: PChar;
begin
  N := Value;
  C := 0;
  while N <> 0 do
  begin
    N := N shr 4;
    Inc(C);
  end;

  if MinDigits < 1 then
    MinDigits := 1;

  if (BuffLen < C) or (BuffLen < MinDigits) then
    Exit(False);

  if C > MinDigits then
    p := @strBuff[C]
  else
    p := @strBuff[MinDigits];

  while Value <> 0 do
  begin
    Dec(p);
    p^ := HexChar[Value and $F];
    Value := Value shr 4;
  end;

  for I := MinDigits - C - 1 downto 0 do
    strBuff[I] := '0';

  Result := True;
end;

function IntToHex(strBuff: PChar; BuffLen: Integer; Value: UInt64; MinDigits: Integer): Boolean;
var
  N: UInt64;
  C, I: Integer;
  p: PChar;
begin
  N := Value;
  C := 0;
  while N <> 0 do
  begin
    N := N shr 4;
    Inc(C);
  end;

  if MinDigits < 1 then
    MinDigits := 1;

  if (BuffLen < C) or (BuffLen < MinDigits) then
    Exit(False);

  if C > MinDigits then
    p := @strBuff[C]
  else
    p := @strBuff[MinDigits];

  while Value <> 0 do
  begin
    Dec(p);
    p^ := HexChar[Value and $F];
    Value := Value shr 4;
  end;

  for I := MinDigits - C - 1 downto 0 do
    strBuff[I] := '0';

  Result := True;
end;

//
// Int128ToHex
//
function Int128ToHex_x86(const Value: UInt128): string;
const
  IntHexChars = SizeOf(Cardinal) * 2;
var
  I: Integer;
begin
  SetLength(Result, SizeOf(Value) * 2);
  for I := 0 to SizeOf(Value) div SizeOf(Cardinal) - 1 do
  begin
    IntToHex(PChar(@(PChar(Result)[I * IntHexChars])), IntHexChars, Value.u32[I], IntHexChars);
  end;
end;

function Int128ToHex_x64(const Value: UInt128): string;
const
  IntHexChars = SizeOf(UInt64) * 2;
var
  I: Integer;
begin
  SetLength(Result, SizeOf(Value) * 2);
  for I := 0 to SizeOf(Value) div SizeOf(UInt64) - 1 do
  begin
    IntToHex(PChar(@(PChar(Result)[I * IntHexChars])), IntHexChars, Value.u64[I], IntHexChars);
  end;
end;


function ROTL32(X: Cardinal; R: Integer): Cardinal; inline;
begin
  Result:= (X shl R) or (X shr (32 - R));
end;

function ROTL64(X: UInt64; R: Integer): UInt64; inline;
begin
  Result:= (X shl R) or (X shr (64 - R));
end;

procedure Fmix32(var H: Cardinal); inline;
begin
  H := H xor (H shr 16);
  H := H * $85ebca6b;
  H := H xor (H shr 13);
  H := H * $c2b2ae35;
  H := H xor (H shr 16);
end;

procedure Fmix64(var H: UInt64); inline;
begin
  H := H xor (H shr 33);
  H := H * UInt64($ff51afd7ed558ccd);
  H := H xor (H shr 33);
  H := H * UInt64($c4ceb9fe1a85ec53);
  H := H xor (H shr 33);
end;

// 呃... 不知道為什麼這裡的效能會比 TMurmurHash3_32bit_x86 的效能差那麼多，
// 並且 MurmurHash3 32bit 使用機率最高，所以將 X86 與 X64 部分使用組合語言。
// 目前測得數值：
// * 這裡測試的數值只是參考，只是用來表示差異。
//
// I don't know why Delphi the efficiency here after Pascal compilation is
// so much worse than TMurmurHash3_32bit_x86.
// Furthermore, MurmurHash3 32-bit has the highest usage probability.
// Therefore, both the X86 and X64 parts will use assembly language.
// Measured values currently:
// * The values tested here are for reference only, just to show the difference.
//
//   A = TMurmurHash3_32bit_x86, B = 本函數
//   A = TMurmurHash3_32bit_x86, B = This function
//
//   X86 Pascal A 666t / X86 Pascal B 976t =  68.23%
//   X64 Pascal A 672t / X64 Pascal B 970t =  69.27%
//   X86 Pascal A 666t / X86 ASM    B 254t = 262.20%
//   X64 Pascal A 672t / X64 ASM    B 249t = 269.87%
//
//   X86 ASM    B 254t / X64 ASM    B 249t = 102.00%
//
// 目前看起來 MurmurHash3_32bit_x86 ASM 在 X86 與 X64 編譯後執行速度很可能極度接近，
// 只是我沒有進行高次數的測試，所以尚未取得更短的時間，這也取決於測試環境。
//
// It currently appears that the execution speed of MurmurHash3_32bit_x86 ASM,
// after compilation for both X86 and X64, is likely to be extremely close;
// just shorter times were simply not achieved during testing.
//
function MurmurHash3_32bit_x86(const Data; Len: Cardinal; Seed: Cardinal): Cardinal;
{$IF Defined(CPUX86) AND Defined(UseASM)}
asm // parameter: eax(Data), edx(Len), ecx(Seed)
  // begin                 // 進入函數
  // 依照官方 Delphi 文件 X86 編譯器 EDI, ESI, ESP, EBP, EBX
  // 這些暫存器退出函數時都必須還原。
  // 所以期間使用到的都必須還原，因此在開頭先行推入堆疊以保存數值。
  push ebx                 // 推入堆疊以保留暫存器值
  push esi

  mov  ebx, Data           // 複製 Data(資料指標) 至 pBlock(暫存器 ebx)

  //
  // 處理完整區塊區段
  //

  // nBlocks := Len div 4;
  mov  esi, Len            // 由 Len 複製值至 nBlocks(暫存器 esi)

  shr  esi, $02            // nBlocks 整除 4；SHR 會改變 CPU 旗標，運算後值為零時 ZF = 1 否則 ZF = 0
  // for I := 1 to nBlocks do
  jz   @@endloop0          // 若 nBlocks 為 0 則轉跳至 endloop0；當 CPU 旗標 ZF = 1 時轉跳

  // >> 已對齊區塊的計算
  .align 16                // 用於產生編譯時對齊指令的偽指令，使轉跳點(@@loop0)的指令對齊
@@loop0:
  // K := pBlock^;
  mov  eax, [ebx]          // 取得 pBlock 位址的值 至 K(暫存器 EAX)
  // Inc(pBlock);
  add  ebx, $04            // 將 pBlock 的值(位址) 增加 4，也就是向後移動 4Byte
  // K := K * $cc9e2d51;
  imul eax, eax, $cc9e2d51 // 將 K 值乘上 $cc9e2d51
  // K := ROTL32(K, 15);
  rol  eax, $0f            // K 的位元向左循環位移 15 次
  // K := K * $1b873593;
  imul eax, eax, $1b873593 // 將 K 值乘 $1b873593
  // H := H xor K;
  xor  ecx, eax            // H(暫存器 ECX) 與 K XOR 後放入 H(暫存器 ECX)
  // H := ROTL32(H, 13);
  rol  ecx, $0d            // H 的位元向左循環位移 13 次
  // H := H * 5 + $e6546b64;
  lea  ecx, [ecx+ecx*4]    // 將 H 值乘上 5
  add  ecx, $e6546b64      // 將 H 值加上 $e6546b64

  // for I := 1 to nBlocks do
  dec  esi                 // 將 nBlocks - 1；DEC 值若為零 ZF = 1，不是零 ZF = 0
  jnz  @@loop0             // 若 nBlocks 不是 0 則跳回到 loop0；ZF = 0 則轉跳
  // << 已對齊區塊的計算

@@endloop0:

  // nLastBytes := Len and 3;
  mov  eax, Len            // 將 Len(暫存器 EDX) 複製到 暫存器 EAX
  and  eax, $03            // 取 4 的餘數，Len and 3 截斷後只留下 0 ~ 3 的值等同於 Len mod 4
  jz   @@if0               // 如果 nLastBytes 為 0 (ZF = 1)則轉跳至 @@if0

  //
  // 處理剩餘區資料(尾端不足一個區塊的資料量)
  //

  // Inc(PByte(pBlock), nLastBytes - 1);
  add  ebx, eax
  dec  ebx

  // if nLastBytes = 2 then goto @@if2 else if nLastBytes > 2 then goto @@if1;
  // >> if nLastBytes = 2 then ...
  cmp  eax, 2              // 比較上面的值 (Len mod 4) 與 2 相比 (CPU 會設定判斷結果旗標)
  
  // K := 0;
  mov  eax, 0              // 清除 EAX 為 0 (MOV 指令不會變動 CPU 旗標)
  
  je   @@if2               // 如果等於 2，這裡也就表示 nLastBytes = 2 (依據前面 CMP 的旗標)
  jb   @@if1               // 如果小於 2，這裡也就表示 nLastBytes = 1 (依據前面 CMP 的旗標)
  // << if nLastBytes = 2 then ...

  // 下面利用組合語言 32bit 處理時 使用 AL 會保留前面的 24bit 的特性，
  // mov al, [r9] 將達成 K := K or PByte(pBlock)^ 的效果。
  
  // K := K or PByte(pBlock)^; Dec(PByte(pBlock)); K := K shl 8;
@@if3:                     // nLastBytes = 3
  mov   al, [ebx]          // 取得尾端倒數第 3 個 Byte 值
  dec  ebx                 // 前往下一個位元組的指標
  shl  eax, 8              // 將位元向左移動 1Byte

  // K := K or PByte(pBlock)^; Dec(PByte(pBlock)); K := K shl 8;
@@if2:                     // nLastBytes = 2
  mov   al, [ebx]          // 取得尾端倒數第 2 個 Byte 值
  dec  ebx                 // 前往下一個位元組的指標
  shl  eax, 8              // 將位元向左移動 1Byte

  // K := K or PByte(pBlock)^;
@@if1:                     // nLastBytes = 1
  mov   al, [ebx]          // 取得尾端倒數第 1 個 Byte 值


  // K := K * $cc9e2d51;
  imul eax, eax, $cc9e2d51 // 將 K 值乘 $cc9e2d51
  // K := ROTL32(K, 15);
  rol  eax, $0f            // K 的位元向左循環位移 15 次
  // K := K * $1b873593;
  imul eax, eax, $1b873593 // 將 K 值乘 $1b873593
  // H := H xor K;
  xor  ecx, eax            // 將 H(暫存器 ECX) XOR K(暫存器 EAX)

@@if0:                     // (Len mod 4) = 0
  //
  // 終結計算
  //

  // H := H xor Len;
  xor  ecx, Len            // 將 H(暫存器 ECX) XOR Len(暫存器 EDX)

  // 下面為 Fmix32(H) 的展開，這段利用交互使用暫存器做運算，以配合剛好輸出到 EAX

  // H := H xor (H shr 16);
  mov  eax, ecx            // 將 H(暫存器 ECX) 複製到 暫存器 EAX
  shr  ecx, $10            // 將 暫存器 ECX 右移 16 次
  xor  eax, ecx            // 將 暫存器 EAX XOR 暫存器 ECX
  // H := H * $85ebca6b;
  imul eax, eax, $85ebca6b // 將 暫存器 EAX 值乘 $85ebca6b
  // H := H xor (H shr 13);
  mov  ecx, eax            // 將 暫存器 EAX 複製到 暫存器 ECX
  shr  eax, $0d            // 將 暫存器 EAX 右移 13 次
  xor  ecx, eax            // 將 暫存器 ECX XOR 暫存器 EAX
  // H := H * $c2b2ae35;
  imul ecx, ecx, $c2b2ae35 // 將 暫存器 ECX 值乘 $c2b2ae35
  //H := H xor (H shr 16);
  mov  eax, ecx            // 將 暫存器 ECX 複製到 暫存器 EAX
  shr  ecx, $10            // 將 暫存器 ECX 右移 16 次
  xor  eax, ecx            // 將 暫存器 EAX XOR 暫存器 ECX，這也是最終輸出

  // Result := H;
//  mov  Result, eax // 這裡已經輸出到結果 暫存器 EAX，因此不需要了

  // end;                  // 函數結束
  pop  esi                 // 由堆疊取出以還原 暫存器 值
  pop  ebx
end;
{$ELSE CPUX86 AND UseASM}
{$IF Defined(CPUX64) AND Defined(UseASM)}
// X64 與 X86 步驟上差不多，只是使用的暫存器略有不同而已，因此改用其他方式表示。
asm // parameter: RCX(Data), RDX(Len), R8D(Seed)
  // begin
  // 依照官方 Delphi 文件 X64 編譯器 R12...R15, RDI, RSI, RBX, RBP, RSP, XMM4...XXMM15
  // 這些暫存器退出函數時都必須還原。
  // 但沒用到其他暫存器與堆疊，所以不需要前置的保存動作

  mov   r9, rcx            // pBlock := PCardinal(@Data);

  //
  // 處理完整區塊區段
  //

  // nBlocks := Len div 4; // 由於後面不需要保持 nBlocks 因此 nBlocks 也是做為 I
  mov  r10, rdx            // I := Len
  shr  r10, $02            // I := I div 4
  // for I := 1 to nBlocks do
  jz  @@endloop0           // if I = 0 then goto @@endloop0

  .align 16                // 用於產生編譯時對齊指令的偽指令，使轉跳點(@@loop0)的指令對齊
@@loop0:
  mov  eax, [r9]           // K := pBlock^;
  add   r9, $04            // Inc(pBlock);
  imul eax, eax, $cc9e2d51 // K := K * $cc9e2d51;
  rol  eax, $0f            // K := ROTL32(K, 15);
  imul eax, eax, $1b873593 // K := K * $1b873593;
  xor   r8, rax            // H := H xor K;
  rol  r8d, $0d            // H := ROTL32(H, 13);

  // H := H * 5 + $e6546b64;
  lea  r8, [r8+r8*4]       // H := H * 5
  add  r8d, $e6546b64      // H := H + $e6546b64

  // for I := 1 to nBlocks do
  dec  r10                 // Dec(I)
  jnz  @@loop0             // if I <> 0 then goto @@endloop0

@@endloop0:
  //
  // 處理尾端非完整區塊
  //

  // nLastBytes := Len and 3;
  mov  rax, rdx            // nLastBytes := Len;
  and  rax, $03            // nLastBytes := nLastBytes and 3;
  jz   @@if0               // if nLastBytes = 0 then @@if0;

  // Dec(PByte(pBlock), nLastBytes - 1);
  add   r9, rax            // Inc(PByte(pBlock), nLastBytes);
  dec   r9                 // Dec(PByte(pBlock));

  // if nLastBytes = 2 then goto @@if2 else if nLastBytes > 2 then goto @@if1;
  // >> if nLastBytes = 2 then ...
  cmp  rax, 2              // 這裡將取得 nLastBytes = 2 判斷結果(旗標)，之後給 je 與 jb 判斷
  mov  rax, 0              // K := 0; (MOV 指令不會變動標)
  je   @@if2               // if nLastBytes = 2 then goto @@if2;
  jb   @@if1               // if nLastBytes > 2 then goto @@if1;
  // << if nLastBytes = 2 then ...

  // 下面利用組合語言 32bit 處理時 使用 AL 會保留前面的 24bit 的特性，
  // mov al, [r9] 將達成 K := K or PByte(pBlock)^ 的效果。
  //
  // 與 x86 些微不同，當 x64 只有操作低位元 32bit 時則會清除高位元 32bit 為 0，
  // 所以 mov al, [r9] 後高位元 32bit 將清除為 0，其值將為 00000000????????。
  
@@if3:                     // nLastBytes >= 3
  mov   al, [r9]           // K := K or PByte(pBlock)^;
  dec   r9                 // Dec(PByte(pBlock));
  shl  rax, 8              // K := K shl 8;

@@if2:                     // nLastBytes >= 2
  mov   al, [r9]           // K := K or PByte(pBlock)^;
  dec   r9                 // Dec(PByte(pBlock));
  shl  rax, 8              // K := K shl 8;

@@if1:                     // nLastBytes >= 1
  mov   al, [r9]           // K := K or PByte(pBlock)^;


  imul eax, eax, $cc9e2d51 // K := K * $cc9e2d51;
  rol  eax, $0f            // K := ROTL32(K, 15);
  imul eax, eax, $1b873593 // K := K * $1b873593;
  xor   r8, rax            // H := H xor K;

@@if0:
  //
  // 終結計算
  //

  xor  r8, rdx             // H := H xor Len;

  // Fmix32(H);
  mov  rax, r8             // {H} :=  H
  shr  r8d, $10            //  H  :=  H  shr 16;
  xor  rax, r8             // {H} := {H} xor H;
  imul eax, eax, $85ebca6b // {H} := {H}  *  $85ebca6b;
  mov   r8, rax            //  H  := {H}
  shr  eax, $0d            // {H} := {H} shr 13;
  xor   r8, rax            //  H  :=  H  xor {H};
  imul r8d, r8d, $c2b2ae35 //  H  :=  H   *  $c2b2ae35;
  mov  rax, r8             // {H} :=  H
  shr   r8, $10            //  H  :=  H  shr 16;
  xor  rax, r8             // {H} := {H} xor H;

//  mov  Result, rax         // Result := H; // 回傳就是 rax 所以這行不需要

  // end;                  // 無值需要還原
end;
{$ELSE CPUX86 AND UseASM}
var
  I, nBlocks, nLastBytes: Integer;
  H, K: Cardinal;
  pBlock: PCardinal;
  pLeftover: PByte;
begin
  H := Seed;

  //
  // 處理完整區塊區段
  //
  pBlock := PCardinal(@Data);
  nBlocks := Len div 4;
  for I := 1 to nBlocks do
  begin
    K := pBlock^;
    Inc(pBlock);

    K := K * $cc9e2d51;
    K := ROTL32(K, 15);
    K := K * $1b873593;

    H := H xor K;
    H := ROTL32(H, 13);
    H := H * 5 + $e6546b64;
  end;

  //
  // 處理尾端非完整區塊
  //
  nLastBytes := Len and 3;
  if nLastBytes <> 0 then
  begin
    pLeftover := PByte(pBlock);
	
    case nLastBytes of
      3: K := (Cardinal(pLeftover[2]) shl 16) or PWord(pLeftover)^;
      2: K := Cardinal(PWord(pLeftover)^);
      1: K := Cardinal(pLeftover^);
    end;

    K := K * $cc9e2d51;
    K := ROTL32(K, 15);
    K := K * $1b873593;
    H := H xor K;
  end;

  //
  // 終結計算
  //
  H := H xor Len;
  Fmix32(H);

  Result := H;
end;
{$IFEND CPUX64 AND UseASM}
{$IFEND CPUX86 AND UseASM}


function MurmurHash3_128bit_x86(const Data; Len: Cardinal; Seed: Cardinal): UInt128;
const
  C1: Cardinal = $239b961b;
  C2: Cardinal = $ab0e9789;
  C3: Cardinal = $38b34ae5;
  C4: Cardinal = $a1e38b93;
var
  I, nBlocks, nLastBytes: Integer;
  H, K: UInt128;
  pBlock: PUInt128;
  pLeftover: PByte;
begin
  H.u32[0] := Seed;
  H.u32[1] := Seed;
  H.u32[2] := Seed;
  H.u32[3] := Seed;

  //
  // 處理完整區塊區段
  //
  pBlock := PUInt128(@Data);
  nBlocks := Len div 16;
  for I := 0 to nBlocks - 1 do
  begin
    K := pBlock^;
    Inc(pBlock);

    K.u32[0] := K.u32[0] * C1;
    K.u32[0] := ROTL32(K.u32[0], 15);
    K.u32[0] := K.u32[0] * C2;
    H.u32[0] := H.u32[0] xor K.u32[0];

    H.u32[0] := ROTL32(H.u32[0], 19);
    Inc(H.u32[0], H.u32[1]);
    H.u32[0] := H.u32[0] * 5 + $561ccd1b;

    K.u32[1] := K.u32[1] * C2;
    K.u32[1] := ROTL32(K.u32[1],16);
    K.u32[1] := K.u32[1] * C3;
    H.u32[1] := H.u32[1] xor K.u32[1];

    H.u32[1] := ROTL32(H.u32[1], 17);
    Inc(H.u32[1], H.u32[2]);
    H.u32[1] := H.u32[1] * 5 + $0bcaa747;

    K.u32[2] := K.u32[2] * C3;
    K.u32[2] := ROTL32(K.u32[2], 17);
    K.u32[2] := K.u32[2] * C4;
    H.u32[2] := H.u32[2] xor K.u32[2];

    H.u32[2] := ROTL32(H.u32[2], 15);
    Inc(H.u32[2], H.u32[3]);
    H.u32[2] := H.u32[2] * 5 + $96cd1c35;

    K.u32[3] := K.u32[3] * C4;
    K.u32[3] := ROTL32(K.u32[3], 18);
    K.u32[3] := K.u32[3] * C1;
    H.u32[3] := H.u32[3] xor K.u32[3];

    H.u32[3] := ROTL32(H.u32[3], 13);
    Inc(H.u32[3], H.u32[0]);
    H.u32[3] := H.u32[3] * 5 + $32ac3b17;
  end;

  //
  // 處理尾端非完整區塊
  //
  nLastBytes := Len and 15;
  if nLastBytes <> 0 then
  begin
    pLeftover := PByte(pBlock);
    K.u32[0] := 0;
    K.u32[1] := 0;
    K.u32[2] := 0;
    K.u32[3] := 0;
    Move(pLeftover^, K, nLastBytes);

    K.u32[3] := K.u32[3] * C4;
    K.u32[3] := ROTL32(K.u32[3], 18);
    K.u32[3] := K.u32[3] * C1;
    H.u32[3] := H.u32[3] xor K.u32[3];

    K.u32[2] := K.u32[2] * C3;
    K.u32[2] := ROTL32(K.u32[2], 17);
    K.u32[2] := K.u32[2] * C4;
    H.u32[2] := H.u32[2] xor K.u32[2];

    K.u32[1] := K.u32[1] * C2;
    K.u32[1] := ROTL32(K.u32[1], 16);
    K.u32[1] := K.u32[1] * C3;
    H.u32[1] := H.u32[1] xor K.u32[1];

    K.u32[0] := K.u32[0] * C1;
    K.u32[0] := ROTL32(K.u32[0], 15);
    K.u32[0] := K.u32[0] * C2;
    H.u32[0] := H.u32[0] xor K.u32[0];
  end;

  //
  // 終結計算
  //
  H.u32[0] := H.u32[0] xor Len;
  H.u32[1] := H.u32[1] xor Len;
  H.u32[2] := H.u32[2] xor Len;
  H.u32[3] := H.u32[3] xor Len;

  Inc(H.u32[0], H.u32[1]);
  Inc(H.u32[0], H.u32[2]);
  Inc(H.u32[0], H.u32[3]);
  Inc(H.u32[1], H.u32[0]);
  Inc(H.u32[2], H.u32[0]);
  Inc(H.u32[3], H.u32[0]);

  Fmix32(H.u32[0]);
  Fmix32(H.u32[1]);
  Fmix32(H.u32[2]);
  Fmix32(H.u32[3]);

  Inc(H.u32[0], H.u32[1]);
  Inc(H.u32[0], H.u32[2]);
  Inc(H.u32[0], H.u32[3]);
  Inc(H.u32[1], H.u32[0]);
  Inc(H.u32[2], H.u32[0]);
  Inc(H.u32[3], H.u32[0]);

  Result.u32[0] := H.u32[0];
  Result.u32[1] := H.u32[1];
  Result.u32[2] := H.u32[2];
  Result.u32[3] := H.u32[3];
end;

function MurmurHash3_128bit_x64(const Data; Len: Cardinal; Seed: Cardinal): UInt128;
const
  C1: UInt64 = UInt64($87c37b91114253d5);
  C2: UInt64 = UInt64($4cf5ad432745937f);
var
  H, K: UInt128;
  I, nBlocks, nLastBytes: Integer;
  pBlock: PUInt128;
  pLeftover: PByte;
begin
  H.u64[0] := Seed;
  H.u64[1] := Seed;

  //
  // 處理完整區塊區段
  //
  pBlock := PUInt128(@Data);
  nBlocks := Len div 16;
  for I := 0 to nBlocks - 1 do
  begin
    K.u64[0] := pBlock.u64[0];
    K.u64[1] := pBlock.u64[1];
    Inc(pBlock);

    K.u64[0] := K.u64[0] * C1;
    K.u64[0] := ROTL64(K.u64[0], 31);
    K.u64[0] := K.u64[0] * C2;
    H.u64[0] := H.u64[0] xor K.u64[0];

    H.u64[0] := ROTL64(H.u64[0], 27);
    Inc(H.u64[0], H.u64[1]);
    H.u64[0] := H.u64[0] * 5 + $52dce729;

    K.u64[1] := K.u64[1] * C2;
    K.u64[1] := ROTL64(K.u64[1], 33);
    K.u64[1] := K.u64[1] * C1;
    H.u64[1] := H.u64[1] xor K.u64[1];

    H.u64[1] := ROTL64(H.u64[1], 31);
    Inc(H.u64[1], H.u64[0]);
    H.u64[1] := H.u64[1] * 5 + $38495ab5;
  end;

  //
  // 處理尾端非完整區塊
  //
  nLastBytes := Len and 15;
  if nLastBytes <> 0 then
  begin
    pLeftover := PByte(pBlock);
    K.u64[0] := 0;
    K.u64[1] := 0;
    Move(pLeftover^, K, nLastBytes);

    K.u64[1] := K.u64[1] * C2;
    K.u64[1] := ROTL64(K.u64[1], 33);
    K.u64[1] := K.u64[1] * C1;
    H.u64[1] := H.u64[1] xor K.u64[1];

    K.u64[0] := K.u64[0] * C1;
    K.u64[0] := ROTL64(K.u64[0], 31);
    K.u64[0] := K.u64[0] * C2;
    H.u64[0] := H.u64[0] xor K.u64[0];
  end;

  //
  // 終結計算
  //
  H.u64[0] := H.u64[0] xor Len;
  H.u64[1] := H.u64[1] xor Len;

  Inc(H.u64[0], H.u64[1]);
  Inc(H.u64[1], H.u64[0]);

  Fmix64(H.u64[0]);
  Fmix64(H.u64[1]);

  Inc(H.u64[0], H.u64[1]);
  Inc(H.u64[1], H.u64[0]);

  Result.u64[0] := H.u64[0];
  Result.u64[1] := H.u64[1];
end;


// 以小區塊(ABuffer)作為緩衝，若緩衝未滿則從 AData 中取資料放置緩衝中，若已滿則略過。
// ABuffer 緩衝區
// ACount  緩衝區使用大小
// AData   來源資料
// ALength 來源資料長度
// Result  輸出已複製到緩衝區的資料長度

// Uses a small block (ABuffer) as a buffer. If the buffer is not full,
// data is taken from AData and placed into the buffer; otherwise, it is skipped.
// ABuffer   The buffer
// ACount    The used size of the buffer
// AData     Source data
// ALength   Length of the source data
// Result    Output: The length of the data successfully copied into the buffer
function GetDataBlockFlowing32bit(var ABuffer: Cardinal; var ACount: Cardinal; const AData: PByte; ALength: Cardinal): Cardinal; inline;
var
  Value, Available: Cardinal;
begin
  if (ACount >= SizeOf(ABuffer)) or (ALength = 0) then
    Exit(0);

  //
  // Result 為要複到緩衝區的位元組數量
  //
  Available := SizeOf(ABuffer) - ACount;
  if ALength > Available then
    Result := Available // 超過緩衝區大小時僅接受剩餘緩衝長度的資料長度
  else
    Result := ALength;  // 要複製到緩衝區的資料長度

  // 將資料接續複製到緩衝區中
  //
  if ALength >= SizeOf(Cardinal) then // 若來源長度大於等於 4 則以 Cardinal 直接複製
    Value := (PCardinal(AData)^ and (Cardinal.MaxValue shr ((SizeOf(Cardinal) - Result) * 8))) shl (ACount * 8)
  else // 若來源長度不足 4 則在範圍內複製
    case Result of
      3: Value := ((Cardinal(PByte(AData)[2]) shl 16) or PWord(AData)^) shl (ACount * 8);
      2: Value := Cardinal(PWord(AData)^) shl (ACount * 8);
      1: Value := Cardinal(PByte(AData)^) shl (ACount * 8);
      else Exit;
    end;
  ABuffer := ABuffer or Value; // 與尚未處理的資料串接資料
  Inc(ACount, Result);         // 設定新的已使用緩衝長度
end;

function GetDataBlockFlowing128bit(var ABuffer: UInt128; var ACount: Cardinal; const AData: PByte; ALength: Cardinal): Cardinal; inline;
var
  Available: Cardinal;
begin
  if (ACount >= SizeOf(ABuffer)) or (ALength = 0) then
    Exit(0);

  //
  // Result 為要複到緩衝區的位元組數量
  //
  Available := SizeOf(ABuffer) - ACount;
  if ALength > Available then
    Result := Available // 超過緩衝區大小時僅接受剩餘緩衝長度的資料長度
  else
    Result := ALength;  // 要複製到緩衝區的資料長度

  // 將資料接續複製到緩衝區中
  Move(AData^, ABuffer.u8[ACount], Result);

  Inc(ACount, Result);  // 設定新的已使用緩衝長度
end;

{ UInt128 }

function UInt128.ToString: string;
begin
  SetLength(Result, SizeOf(Self) * 2);
  BinToHex(Self, PChar(Result), SizeOf(Self));
end;

function UInt128.ToStringX86: string;
begin
  Result := Int128ToHex_x86(Self);
end;

function UInt128.ToStringX64: string;
begin
  Result := Int128ToHex_x64(Self);
end;


{ TMurmurHash3_32bit_x86 }

class function TMurmurHash3_32bit_x86.Create: TMurmurHash3_32bit_x86;
begin
  Result.Initialize;
end;

procedure TMurmurHash3_32bit_x86.Scramble(var K: Cardinal);
begin
  K := K * C1;
  K := ROTL32(K, R1);
  K := K * C2;
end;

procedure TMurmurHash3_32bit_x86.Compress(var H: Cardinal; K: Cardinal);
begin
  Scramble(K);
  H := H xor K;
  H := ROTL32(H, R2);
  H := H * M + N;
end;

class function TMurmurHash3_32bit_x86.Create(ASeed: Cardinal): TMurmurHash3_32bit_x86;
begin
  Result.Initialize(ASeed);
end;

procedure TMurmurHash3_32bit_x86.ClearRemainingBuffer;
begin
  FRemainingLength := 0;
  FRemainingData := 0; // FillChar(FRemainingData, SizeOf(FRemainingData), 0);
end;

procedure TMurmurHash3_32bit_x86.Initialize(ASeed: Cardinal);
begin
  FSeed := ASeed;
  Initialize;
end;

procedure TMurmurHash3_32bit_x86.Initialize;
begin
  ClearRemainingBuffer;
  FLength := 0;
  FHashContext := FSeed;
  FFinalized := False;
end;

procedure TMurmurHash3_32bit_x86.Finalize;
var
  K: Cardinal;
begin
  if FRemainingLength <> 0 then
  begin
    case FRemainingLength of
      3: K := FRemainingData and $00FFFFFF;
      2: K := FRemainingData and $0000FFFF;
      1: K := FRemainingData and $000000FF;
    end;
    Inc(FLength, FRemainingLength);
    FRemainingLength := 0;

    Scramble(K);
    FHashContext := FHashContext xor K;
  end;

  //
  // 計算最終值
  //
  FHashContext := FHashContext xor FLength;
  Fmix32(FHashContext);

  FFinalized := True;
end;

procedure TMurmurHash3_32bit_x86.DoDigest;
begin
  if not FFinalized then
    Finalize;
end;

function TMurmurHash3_32bit_x86.GetDigest: TBytes;
begin
  DoDigest;
  SetLength(Result, GetHashSize); // Size of FHash...
  Move(FHashContext, PByte(@Result[0])^, GetHashSize);
end;

procedure TMurmurHash3_32bit_x86.Reset;
begin
  Initialize;
end;

procedure TMurmurHash3_32bit_x86.Update(const AData; ALength: Cardinal);
var
  pData: PByte;
  I, Len: Cardinal;
begin
  if FFinalized then
    raise EHashException.CreateRes(@errCanNotUpdate);

  pData := @AData; // 取得來源資料起始位元組指標

  //
  // 首先處理待處理的資料
  // 若資料不足一個區塊(BlockSize)，則將資料放置緩衝區(FRemainingData)中待下次處理
  //
  // First, process the data to be handled.
  // If the data is less than one block (BlockSize),
  // the data is placed in the buffer (FRemainingData) for later processing.
  //
  if (FRemainingLength <> 0) and (ALength < SizeOf(FRemainingData)) then
  begin
    // 若 FRemainingData 中有待處理資料則將新資料補充到 FRemainingData 剩餘可用空間中
    Len := GetDataBlockFlowing32bit(FRemainingData, FRemainingLength, pData, ALength);
    if FRemainingLength = SizeOf(FRemainingData) then
    begin // 若緩衝資料長度達到處理量(一個 BlockSize)
      Compress(FHashContext, FRemainingData); // 處理資料
      Inc(FLength, SizeOf(FRemainingData));   // 計入已處理總長，用於最終計算
      ClearRemainingBuffer;                   // 清理緩衝區
    end;
    I := ALength - Len; // 剔除上面已處理的長度
    if I = 0 then       // 若已無處理資料則直接退出
      Exit;
    Inc(pData, Len);    // 向後移動指標以跳過上面已由來源取出的資料
  end
  else
  begin
    I := ALength;
  end;

  //
  // 處理已對齊的區塊的資料
  //
  Inc(FLength, I and (not (SizeOf(Cardinal) - 1))); // 加上對齊區塊(4byte)的長度
  while I >= BlockSize do
  begin
    Compress(FHashContext, PCardinal(pData)^); // 處理區塊資料
    Inc(pData, BlockSize);                     // 移動至下一個區塊
    Dec(I, BlockSize);                         // 扣除已處理長度
  end;

  // 若仍有資料未處理則將資料推入至緩衝區(FRemainingData)
  GetDataBlockFlowing32bit(FRemainingData, FRemainingLength, pData, I);
end;

procedure TMurmurHash3_32bit_x86.Update(const AData: TBytes; ALength: Cardinal);
begin
  if ALength = 0 then
    Update(PByte(AData)^, Length(AData))
  else
    Update(PByte(AData)^, ALength);
end;

procedure TMurmurHash3_32bit_x86.Update(const Input: string);
begin
  Update(PChar(Input)^, Input.Length * SizeOf(Char));
end;

function TMurmurHash3_32bit_x86.GetBlockSize: Integer;
begin
  Result := BlockSize;
end;

function TMurmurHash3_32bit_x86.GetHashSize: Integer;
begin
  Result := HashSize;
end;

function TMurmurHash3_32bit_x86.HashAsBytes: TBytes;
begin
  Result := GetDigest;
end;

function TMurmurHash3_32bit_x86.HashAsCardinal: Cardinal;
begin
  DoDigest;
  Result := FHashContext;
end;

function TMurmurHash3_32bit_x86.HashAsString: string;
begin
  DoDigest;
  Result := FHashContext.ToString;
end;

class function TMurmurHash3_32bit_x86.GetHashBytes(const AData: string): TBytes;
var
  FHash: TMurmurHash3_32bit_x86;
begin
  FHash := TMurmurHash3_32bit_x86.Create;
  FHash.Update(AData);
  Result := FHash.GetDigest;
end;

class function TMurmurHash3_32bit_x86.GetHashString(const AString: string): string;
var
  FHash: TMurmurHash3_32bit_x86;
begin
  FHash := TMurmurHash3_32bit_x86.Create;
  FHash.Update(AString);
  Result := FHash.HashAsString;
end;

class function TMurmurHash3_32bit_x86.GetHashBytes(const AStream: TStream): TBytes;
const
  BUFFERSIZE = 4 * 1024;
var
  FHash: TMurmurHash3_32bit_x86;
  LBuffer: TBytes;
  LBytesRead: Longint;
begin
  FHash := TMurmurHash3_32bit_x86.Create;
  SetLength(LBuffer, BUFFERSIZE);
  while True do
  begin
    LBytesRead := AStream.ReadData(LBuffer, BUFFERSIZE);
    if LBytesRead = 0 then
      Break;
    FHash.Update(LBuffer, LBytesRead);
  end;
  Result := FHash.GetDigest;
end;

class function TMurmurHash3_32bit_x86.GetHashString(const AStream: TStream): string;
begin
  Result := THash.DigestAsString(GetHashBytes(AStream));
end;

class function TMurmurHash3_32bit_x86.GetHashBytesFromFile(const AFileName: TFileName): TBytes;
var
  LFile: TFileStream;
begin
  LFile := TFileStream.Create(AFileName, fmShareDenyNone or fmOpenRead);
  try
    Result := GetHashBytes(LFile);
  finally
    LFile.Free;
  end;
end;

class function TMurmurHash3_32bit_x86.GetHashStringFromFile(const AFileName: TFileName): string;
begin
  Result := THash.DigestAsString(GetHashBytesFromFile(AFileName));
end;

class function TMurmurHash3_32bit_x86.GetHMAC(const AData, AKey: string): string;
begin
  Result := THash.DigestAsString(GetHMACAsBytes(AData, AKey));
end;

class function TMurmurHash3_32bit_x86.GetHMACAsBytes(const AData, AKey: string): TBytes;
begin
  Result := GetHMACAsBytes(TEncoding.UTF8.GetBytes(AData), TEncoding.UTF8.GetBytes(AKey));
end;

class function TMurmurHash3_32bit_x86.GetHMACAsBytes(const AData: string; const AKey: TBytes): TBytes;
begin
  Result := GetHMACAsBytes(TEncoding.UTF8.GetBytes(AData), AKey);
end;

class function TMurmurHash3_32bit_x86.GetHMACAsBytes(const AData: TBytes; const AKey: string): TBytes;
begin
  Result := GetHMACAsBytes(AData, TEncoding.UTF8.GetBytes(AKey));
end;

class function TMurmurHash3_32bit_x86.GetHMACAsBytes(const AData, AKey: TBytes): TBytes;
const
  CInnerPad : Byte = $36;
  COuterPad : Byte = $5C;
var
  TempBuffer1: TBytes;
  TempBuffer2: TBytes;
  FKey: TBytes;
  LKey: TBytes;
  I: Integer;
  FHash: TMurmurHash3_32bit_x86;
  LBuffer: TBytes;
begin
  FHash := TMurmurHash3_32bit_x86.Create;

  LBuffer := AData;

  FKey := AKey;
  if Length(FKey) > FHash.GetBlockSize then
  begin
    FHash.Update(FKey);
    FKey := Copy(FHash.GetDigest);
  end;

  LKey := Copy(FKey, 0, MaxInt);
  SetLength(LKey, FHash.GetBlockSize);
  SetLength(TempBuffer1, FHash.GetBlockSize + Length(LBuffer));
  for I := Low(LKey) to High(LKey) do begin
    TempBuffer1[I] := LKey[I] xor CInnerPad;
  end;
  if Length(LBuffer) > 0 then
    Move(LBuffer[0], TempBuffer1[Length(LKey)], Length(LBuffer));

  FHash.Reset;
  FHash.Update(TempBuffer1);
  TempBuffer2 := FHash.GetDigest;

  SetLength(TempBuffer1, FHash.GetBlockSize + FHash.GetHashSize);
  for I := Low(LKey) to High(LKey) do begin
    TempBuffer1[I] := LKey[I] xor COuterPad;
  end;
  Move(TempBuffer2[0], TempBuffer1[Length(LKey)], Length(TempBuffer2));

  FHash.Reset;
  FHash.Update(TempBuffer1);
  Result := FHash.GetDigest;
end;



{ TMurmurHash3_128bit_x86 }

class function TMurmurHash3_128bit_x86.Create: TMurmurHash3_128bit_x86;
begin
  Result.Initialize;
end;

procedure TMurmurHash3_128bit_x86.Scramble1(var K: Cardinal);
begin
  K := K * C1;
  K := ROTL32(K, R1A);
  K := K * C2;
end;

procedure TMurmurHash3_128bit_x86.Scramble2(var K: Cardinal);
begin
  K := K * C2;
  K := ROTL32(K, R2A);
  K := K * C3;
end;

procedure TMurmurHash3_128bit_x86.Scramble3(var K: Cardinal);
begin
  K := K * C3;
  K := ROTL32(K, R3A);
  K := K * C4;
end;

procedure TMurmurHash3_128bit_x86.Scramble4(var K: Cardinal);
begin
  K := K * C4;
  K := ROTL32(K, R4A);
  K := K * C1;
end;

procedure TMurmurHash3_128bit_x86.Scramble(var K: UInt128);
begin
  Scramble1(K.u32[0]);
  Scramble2(K.u32[1]);
  Scramble3(K.u32[2]);
  Scramble4(K.u32[3]);
end;

procedure TMurmurHash3_128bit_x86.Compress1(var HA: Cardinal; HB, K: Cardinal);
begin
  Scramble1(K);
  HA := HA xor K;
  HA := ROTL32(HA, R1B);
  Inc(HA, HB);
  HA := HA * M + N1;
end;

procedure TMurmurHash3_128bit_x86.Compress2(var HA: Cardinal; HB, K: Cardinal);
begin
  Scramble2(K);
  HA := HA xor K;
  HA := ROTL32(HA, R2B);
  Inc(HA, HB);
  HA := HA * M + N2;
end;

procedure TMurmurHash3_128bit_x86.Compress3(var HA: Cardinal; HB, K: Cardinal);
begin
  Scramble3(K);
  HA := HA xor K;
  HA := ROTL32(HA, R3B);
  Inc(HA, HB);
  HA := HA * M + N3;
end;

procedure TMurmurHash3_128bit_x86.Compress4(var HA: Cardinal; HB, K: Cardinal);
begin
  Scramble4(K);
  HA := HA xor K;
  HA := ROTL32(HA, R4B);
  Inc(HA, HB);
  HA := HA * M + N4;
end;

procedure TMurmurHash3_128bit_x86.Compress(var H: UInt128; const K: UInt128);
begin
  Compress1(H.u32[0], H.u32[1], K.u32[0]);
  Compress2(H.u32[1], H.u32[2], K.u32[1]);
  Compress3(H.u32[2], H.u32[3], K.u32[2]);
  Compress4(H.u32[3], H.u32[0], K.u32[3]);
end;

class function TMurmurHash3_128bit_x86.Create(ASeed: Cardinal): TMurmurHash3_128bit_x86;
begin
  Result.Initialize(ASeed);
end;

procedure TMurmurHash3_128bit_x86.ClearRemainingBuffer;
begin
  FRemainingLength := 0;
  FRemainingData.u32[0] := 0;
  FRemainingData.u32[1] := 0;
  FRemainingData.u32[2] := 0;
  FRemainingData.u32[3] := 0;
end;

procedure TMurmurHash3_128bit_x86.Initialize(ASeed: Cardinal);
begin
  FSeed := ASeed;
  Initialize;
end;

procedure TMurmurHash3_128bit_x86.Initialize;
begin
  FLength := 0;
  FHashContext.u32[0] := FSeed;
  FHashContext.u32[1] := FSeed;
  FHashContext.u32[2] := FSeed;
  FHashContext.u32[3] := FSeed;
  ClearRemainingBuffer;
  FFinalized := False;
end;

procedure TMurmurHash3_128bit_x86.Finalize;
var
  K: UInt128;
begin
  //
  // 尾端剩餘資料計算
  //
  if FRemainingLength <> 0 then
  begin
    Move(FRemainingData, K, FRemainingLength);
    if FRemainingLength < SizeOf(K) then
      FillChar(K.u8[FRemainingLength], SizeOf(K) - FRemainingLength, 0);
    Inc(FLength, FRemainingLength);
    FRemainingLength := 0;

    Scramble(K);
    FHashContext.u32[3] := FHashContext.u32[3] xor K.u32[3];
    FHashContext.u32[2] := FHashContext.u32[2] xor K.u32[2];
    FHashContext.u32[1] := FHashContext.u32[1] xor K.u32[1];
    FHashContext.u32[0] := FHashContext.u32[0] xor K.u32[0];
  end;

  //
  // 計算最終值
  //
  FHashContext.u32[3] := FHashContext.u32[3] xor FLength;
  FHashContext.u32[2] := FHashContext.u32[2] xor FLength;
  FHashContext.u32[1] := FHashContext.u32[1] xor FLength;
  FHashContext.u32[0] := FHashContext.u32[0] xor FLength;

  Inc(FHashContext.u32[0], FHashContext.u32[1]);
  Inc(FHashContext.u32[0], FHashContext.u32[2]);
  Inc(FHashContext.u32[0], FHashContext.u32[3]);
  Inc(FHashContext.u32[1], FHashContext.u32[0]);
  Inc(FHashContext.u32[2], FHashContext.u32[0]);
  Inc(FHashContext.u32[3], FHashContext.u32[0]);

  Fmix32(FHashContext.u32[0]);
  Fmix32(FHashContext.u32[1]);
  Fmix32(FHashContext.u32[2]);
  Fmix32(FHashContext.u32[3]);

  Inc(FHashContext.u32[0], FHashContext.u32[1]);
  Inc(FHashContext.u32[0], FHashContext.u32[2]);
  Inc(FHashContext.u32[0], FHashContext.u32[3]);
  Inc(FHashContext.u32[1], FHashContext.u32[0]);
  Inc(FHashContext.u32[2], FHashContext.u32[0]);
  Inc(FHashContext.u32[3], FHashContext.u32[0]);

  FFinalized := True;
end;

procedure TMurmurHash3_128bit_x86.DoDigest;
begin
  if not FFinalized then
    Finalize;
end;

function TMurmurHash3_128bit_x86.GetDigest: TBytes;
begin
  DoDigest;
  SetLength(Result, GetHashSize); // Size of FHash...
  Move(FHashContext, PByte(@Result[0])^, GetHashSize);
end;

procedure TMurmurHash3_128bit_x86.Reset;
begin
  Initialize;
end;

procedure TMurmurHash3_128bit_x86.Update(const AData; ALength: Cardinal);
var
  pData: PByte;
  I, Len: Cardinal;
begin
  if FFinalized then
    raise EHashException.CreateRes(@errCanNotUpdate);

  pData := @AData; // 取得來源資料起始位元組指標

  //
  // 首先處理待處理的資料
  // 若資料不足一個區塊(BlockSize)，則將資料放置緩衝區(FRemainingData)中待下次處理
  //
  if (FRemainingLength <> 0) and (ALength < SizeOf(FRemainingData)) then
  begin
    // 若 FRemainingData 中有待處理資料則將新資料補充到 FRemainingData 剩餘可用空間中
    Len := GetDataBlockFlowing128bit(FRemainingData, FRemainingLength, pData, ALength);
    if FRemainingLength = SizeOf(FRemainingData) then
    begin // 若緩衝資料長度達到處理量
      Compress(FHashContext, FRemainingData); // 處理資料
      Inc(FLength, SizeOf(FRemainingData));   // 計入已處理長度(用於最終計算)
      ClearRemainingBuffer;                   // 清理緩衝區
    end;
    I := ALength - Len; // 剔除上面已處理的長度
    if I = 0 then       // 若已無處理資料則直接退出
      Exit;
    Inc(pData, Len);    // 向後移動指標以跳過上面已由來源取出的資料
  end
  else
  begin
    I := ALength;
  end;

  //
  // 處理已對齊的區塊的資料
  //
  Inc(FLength, I and (not (SizeOf(FHashContext) - 1))); // 加上對齊 16byte 的長度
  while I >= BlockSize do
  begin
    Compress(FHashContext, PUInt128(pData)^); // 處理區塊資料
    Inc(pData, BlockSize);                    // 移動至下一個區塊
    Dec(I, BlockSize);                        // 計算新的剩餘長度
  end;

  // 由來源資料提取尚未處理的資料
  GetDataBlockFlowing128bit(FRemainingData, FRemainingLength, pData, I);
end;

procedure TMurmurHash3_128bit_x86.Update(const AData: TBytes; ALength: Cardinal);
begin
  if ALength = 0 then
    Update(PByte(AData)^, Length(AData))
  else
    Update(PByte(AData)^, ALength);
end;

procedure TMurmurHash3_128bit_x86.Update(const Input: string);
begin
  Update(PChar(Input)^, Input.Length * SizeOf(Char));
end;

function TMurmurHash3_128bit_x86.GetBlockSize: Integer;
begin
  Result := BlockSize;
end;

function TMurmurHash3_128bit_x86.GetHashSize: Integer;
begin
  Result := HashSize;
end;

function TMurmurHash3_128bit_x86.HashAsBytes: TBytes;
begin
  Result := GetDigest;
end;

function TMurmurHash3_128bit_x86.HashAsUInt128: UInt128;
begin
  DoDigest;
  Result := FHashContext;
end;

function TMurmurHash3_128bit_x86.HashAsString: string;
begin
  DoDigest;
  Result := Int128ToHex_x86(FHashContext);
end;

class function TMurmurHash3_128bit_x86.GetHashBytes(const AData: string): TBytes;
var
  FHash: TMurmurHash3_128bit_x86;
begin
  FHash := TMurmurHash3_128bit_x86.Create;
  FHash.Update(AData);
  Result := FHash.GetDigest;
end;

class function TMurmurHash3_128bit_x86.GetHashString(const AString: string): string;
var
  FHash: TMurmurHash3_128bit_x86;
begin
  FHash := TMurmurHash3_128bit_x86.Create;
  FHash.Update(AString);
  Result := FHash.HashAsString;
end;

class function TMurmurHash3_128bit_x86.GetHashBytes(const AStream: TStream): TBytes;
const
  BUFFERSIZE = 4 * 1024;
var
  FHash: TMurmurHash3_128bit_x86;
  LBuffer: TBytes;
  LBytesRead: Longint;
begin
  FHash := TMurmurHash3_128bit_x86.Create;
  SetLength(LBuffer, BUFFERSIZE);
  while True do
  begin
    LBytesRead := AStream.ReadData(LBuffer, BUFFERSIZE);
    if LBytesRead = 0 then
      Break;
    FHash.Update(LBuffer, LBytesRead);
  end;
  Result := FHash.GetDigest;
end;

class function TMurmurHash3_128bit_x86.GetHashString(const AStream: TStream): string;
begin
  Result := THash.DigestAsString(GetHashBytes(AStream));
end;

class function TMurmurHash3_128bit_x86.GetHashBytesFromFile(const AFileName: TFileName): TBytes;
var
  LFile: TFileStream;
begin
  LFile := TFileStream.Create(AFileName, fmShareDenyNone or fmOpenRead);
  try
    Result := GetHashBytes(LFile);
  finally
    LFile.Free;
  end;
end;

class function TMurmurHash3_128bit_x86.GetHashStringFromFile(const AFileName: TFileName): string;
begin
  Result := THash.DigestAsString(GetHashBytesFromFile(AFileName));
end;

class function TMurmurHash3_128bit_x86.GetHMAC(const AData, AKey: string): string;
begin
  Result := THash.DigestAsString(GetHMACAsBytes(AData, AKey));
end;

class function TMurmurHash3_128bit_x86.GetHMACAsBytes(const AData, AKey: string): TBytes;
begin
  Result := GetHMACAsBytes(TEncoding.UTF8.GetBytes(AData), TEncoding.UTF8.GetBytes(AKey));
end;

class function TMurmurHash3_128bit_x86.GetHMACAsBytes(const AData: string; const AKey: TBytes): TBytes;
begin
  Result := GetHMACAsBytes(TEncoding.UTF8.GetBytes(AData), AKey);
end;

class function TMurmurHash3_128bit_x86.GetHMACAsBytes(const AData: TBytes; const AKey: string): TBytes;
begin
  Result := GetHMACAsBytes(AData, TEncoding.UTF8.GetBytes(AKey));
end;

class function TMurmurHash3_128bit_x86.GetHMACAsBytes(const AData, AKey: TBytes): TBytes;
const
  CInnerPad : Byte = $36;
  COuterPad : Byte = $5C;
var
  TempBuffer1: TBytes;
  TempBuffer2: TBytes;
  FKey: TBytes;
  LKey: TBytes;
  I: Integer;
  FHash: TMurmurHash3_128bit_x86;
  LBuffer: TBytes;
begin
  FHash := TMurmurHash3_128bit_x86.Create;

  LBuffer := AData;

  FKey := AKey;
  if Length(FKey) > FHash.GetBlockSize then
  begin
    FHash.Update(FKey);
    FKey := Copy(FHash.GetDigest);
  end;

  LKey := Copy(FKey, 0, MaxInt);
  SetLength(LKey, FHash.GetBlockSize);
  SetLength(TempBuffer1, FHash.GetBlockSize + Length(LBuffer));
  for I := Low(LKey) to High(LKey) do begin
    TempBuffer1[I] := LKey[I] xor CInnerPad;
  end;
  if Length(LBuffer) > 0 then
    Move(LBuffer[0], TempBuffer1[Length(LKey)], Length(LBuffer));

  FHash.Reset;
  FHash.Update(TempBuffer1);
  TempBuffer2 := FHash.GetDigest;

  SetLength(TempBuffer1, FHash.GetBlockSize + FHash.GetHashSize);
  for I := Low(LKey) to High(LKey) do begin
    TempBuffer1[I] := LKey[I] xor COuterPad;
  end;
  Move(TempBuffer2[0], TempBuffer1[Length(LKey)], Length(TempBuffer2));

  FHash.Reset;
  FHash.Update(TempBuffer1);
  Result := FHash.GetDigest;
end;


{ TMurmurHash3_128bit_x64 }

class function TMurmurHash3_128bit_x64.Create: TMurmurHash3_128bit_x64;
begin
  Result.Initialize;
end;

procedure TMurmurHash3_128bit_x64.Scramble1(var K: UInt64);
begin
  K := K * C1;
  K := ROTL64(K, R1A);
  K := K * C2;
end;

procedure TMurmurHash3_128bit_x64.Scramble2(var K: UInt64);
begin
  K := K * C2;
  K := ROTL64(K, R2A);
  K := K * C1;
end;

procedure TMurmurHash3_128bit_x64.Scramble(var K: UInt128);
begin
  Scramble1(K.u64[0]);
  Scramble2(K.u64[1]);
end;

procedure TMurmurHash3_128bit_x64.Compress1(var HA: UInt64; HB, K: UInt64);
begin
  Scramble1(K);
  HA := HA xor K;
  HA := ROTL64(HA, R1B);
  Inc(HA, HB);
  HA := HA * M + N1;
end;

procedure TMurmurHash3_128bit_x64.Compress2(var HA: UInt64; HB, K: UInt64);
begin
  Scramble2(K);
  HA := HA xor K;
  HA := ROTL64(HA, R2B);
  Inc(HA, HB);
  HA := HA * M + N2;
end;

procedure TMurmurHash3_128bit_x64.Compress(var H: UInt128; const K: UInt128);
begin
  Compress1(H.u64[0], H.u64[1], K.u64[0]);
  Compress2(H.u64[1], H.u64[0], K.u64[1]);
end;

class function TMurmurHash3_128bit_x64.Create(ASeed: Cardinal): TMurmurHash3_128bit_x64;
begin
  Result.Initialize(ASeed);
end;

procedure TMurmurHash3_128bit_x64.ClearRemainingBuffer;
begin
  FRemainingLength := 0;
  FRemainingData.u64[0] := 0;
  FRemainingData.u64[1] := 0;
end;

procedure TMurmurHash3_128bit_x64.Initialize(ASeed: Cardinal);
begin
  FSeed := ASeed;
  Initialize;
end;

procedure TMurmurHash3_128bit_x64.Initialize;
begin
  ClearRemainingBuffer;
  FLength := 0;
  FHashContext.u64[0] := FSeed;
  FHashContext.u64[1] := FSeed;
  FFinalized := False;
end;

procedure TMurmurHash3_128bit_x64.Finalize;
var
  K: UInt128;
begin
  //
  // 尾端剩餘資料計算
  //
  if FRemainingLength <> 0 then
  begin
    Move(FRemainingData, K, FRemainingLength);
    if FRemainingLength < SizeOf(K) then
      FillChar(K.u8[FRemainingLength], SizeOf(K) - FRemainingLength, 0);
    Inc(FLength, FRemainingLength);
    FRemainingLength := 0;

    Scramble(K);
    FHashContext.u64[0] := FHashContext.u64[0] xor K.u64[0];
    FHashContext.u64[1] := FHashContext.u64[1] xor K.u64[1];
  end;

  //
  // 計算最終值
  //
  FHashContext.u64[0] := FHashContext.u64[0] xor FLength;
  FHashContext.u64[1] := FHashContext.u64[1] xor FLength;

  Inc(FHashContext.u64[0], FHashContext.u64[1]);
  Inc(FHashContext.u64[1], FHashContext.u64[0]);

  Fmix64(FHashContext.u64[0]);
  Fmix64(FHashContext.u64[1]);

  Inc(FHashContext.u64[0], FHashContext.u64[1]);
  Inc(FHashContext.u64[1], FHashContext.u64[0]);

  FFinalized := True;
end;

procedure TMurmurHash3_128bit_x64.DoDigest;
begin
  if not FFinalized then
    Finalize;
end;

function TMurmurHash3_128bit_x64.GetDigest: TBytes;
begin
  DoDigest;
  SetLength(Result, GetHashSize); // Size of FHash...
  Move(FHashContext, PByte(@Result[0])^, GetHashSize);
end;

procedure TMurmurHash3_128bit_x64.Reset;
begin
  Initialize;
end;

procedure TMurmurHash3_128bit_x64.Update(const AData; ALength: Cardinal);
var
  pData: PByte;
  I, Len: Cardinal;
begin
  if FFinalized then
    raise EHashException.CreateRes(@errCanNotUpdate);

  pData := @AData; // 取得來源資料起始位元組指標

  //
  // 首先處理待處理的資料
  // 若資料不足一個區塊(BlockSize)，則將資料放置緩衝區(FRemainingData)中待下次處理
  //
  if (FRemainingLength <> 0) and (ALength < SizeOf(FRemainingData)) then
  begin
    // 若 FRemainingData 中有待處理資料則將新資料補充到 FRemainingData 剩餘可用空間中
    Len := GetDataBlockFlowing128bit(FRemainingData, FRemainingLength, pData, ALength);
    if FRemainingLength = SizeOf(FRemainingData) then
    begin // 若緩衝資料長度達到處理量
      Compress(FHashContext, FRemainingData); // 處理資料
      Inc(FLength, SizeOf(FRemainingData));   // 計入已處理長度(用於最終計算)
      ClearRemainingBuffer;                   // 清理緩衝區
    end;
    I := ALength - Len; // 剔除上面以處理的長度
    if I = 0 then       // 若已無處理資料則直接退出
      Exit;
    Inc(pData, Len);    // 向後移動指標以跳過上面已由來源取出的資料
  end
  else
  begin
    I := ALength;
  end;

  //
  // 處理已對齊的區塊的資料
  //
  Inc(FLength, I and (not (SizeOf(FHashContext) - 1))); // 加上對齊 16byte 的長度
  while I >= BlockSize do
  begin
    Compress(FHashContext, PUInt128(pData)^);

    Inc(pData, BlockSize); // 移動至下一個區塊
    Dec(I, BlockSize);     // 計算新的剩餘長度
  end;

  // 若仍有資料未處理則將資料推入至緩衝區(FRemainingData)
  GetDataBlockFlowing128bit(FRemainingData, FRemainingLength, pData, I);
end;

procedure TMurmurHash3_128bit_x64.Update(const AData: TBytes; ALength: Cardinal);
begin
  if ALength = 0 then
    Update(PByte(AData)^, Length(AData))
  else
    Update(PByte(AData)^, ALength);
end;

procedure TMurmurHash3_128bit_x64.Update(const Input: string);
begin
  Update(PChar(Input)^, Input.Length * SizeOf(Char));
end;

function TMurmurHash3_128bit_x64.GetBlockSize: Integer;
begin
  Result := BlockSize;
end;

function TMurmurHash3_128bit_x64.GetHashSize: Integer;
begin
  Result := HashSize;
end;

function TMurmurHash3_128bit_x64.HashAsBytes: TBytes;
begin
  Result := GetDigest;
end;

function TMurmurHash3_128bit_x64.HashAsUInt128: UInt128;
begin
  DoDigest;
  Result := FHashContext;
end;

function TMurmurHash3_128bit_x64.HashAsString: string;
begin
  DoDigest;
  Result := Int128ToHex_x64(FHashContext);
end;

class function TMurmurHash3_128bit_x64.GetHashBytes(const AData: string): TBytes;
var
  FHash: TMurmurHash3_128bit_x64;
begin
  FHash := TMurmurHash3_128bit_x64.Create;
  FHash.Update(AData);
  Result := FHash.GetDigest;
end;

class function TMurmurHash3_128bit_x64.GetHashString(const AString: string): string;
var
  FHash: TMurmurHash3_128bit_x64;
begin
  FHash := TMurmurHash3_128bit_x64.Create;
  FHash.Update(AString);
  Result := FHash.HashAsString;
end;

class function TMurmurHash3_128bit_x64.GetHashBytes(const AStream: TStream): TBytes;
const
  BUFFERSIZE = 4 * 1024;
var
  FHash: TMurmurHash3_128bit_x64;
  LBuffer: TBytes;
  LBytesRead: Longint;
begin
  FHash := TMurmurHash3_128bit_x64.Create;
  SetLength(LBuffer, BUFFERSIZE);
  while True do
  begin
    LBytesRead := AStream.ReadData(LBuffer, BUFFERSIZE);
    if LBytesRead = 0 then
      Break;
    FHash.Update(LBuffer, LBytesRead);
  end;
  Result := FHash.GetDigest;
end;

class function TMurmurHash3_128bit_x64.GetHashString(const AStream: TStream): string;
begin
  Result := THash.DigestAsString(GetHashBytes(AStream));
end;

class function TMurmurHash3_128bit_x64.GetHashBytesFromFile(const AFileName: TFileName): TBytes;
var
  LFile: TFileStream;
begin
  LFile := TFileStream.Create(AFileName, fmShareDenyNone or fmOpenRead);
  try
    Result := GetHashBytes(LFile);
  finally
    LFile.Free;
  end;
end;

class function TMurmurHash3_128bit_x64.GetHashStringFromFile(const AFileName: TFileName): string;
begin
  Result := THash.DigestAsString(GetHashBytesFromFile(AFileName));
end;

class function TMurmurHash3_128bit_x64.GetHMAC(const AData, AKey: string): string;
begin
  Result := THash.DigestAsString(GetHMACAsBytes(AData, AKey));
end;

class function TMurmurHash3_128bit_x64.GetHMACAsBytes(const AData, AKey: string): TBytes;
begin
  Result := GetHMACAsBytes(TEncoding.UTF8.GetBytes(AData), TEncoding.UTF8.GetBytes(AKey));
end;

class function TMurmurHash3_128bit_x64.GetHMACAsBytes(const AData: string; const AKey: TBytes): TBytes;
begin
  Result := GetHMACAsBytes(TEncoding.UTF8.GetBytes(AData), AKey);
end;

class function TMurmurHash3_128bit_x64.GetHMACAsBytes(const AData: TBytes; const AKey: string): TBytes;
begin
  Result := GetHMACAsBytes(AData, TEncoding.UTF8.GetBytes(AKey));
end;

class function TMurmurHash3_128bit_x64.GetHMACAsBytes(const AData, AKey: TBytes): TBytes;
const
  CInnerPad : Byte = $36;
  COuterPad : Byte = $5C;
var
  TempBuffer1: TBytes;
  TempBuffer2: TBytes;
  FKey: TBytes;
  LKey: TBytes;
  I: Integer;
  FHash: TMurmurHash3_128bit_x64;
  LBuffer: TBytes;
begin
  FHash := TMurmurHash3_128bit_x64.Create;

  LBuffer := AData;

  FKey := AKey;
  if Length(FKey) > FHash.GetBlockSize then
  begin
    FHash.Update(FKey);
    FKey := Copy(FHash.GetDigest);
  end;

  LKey := Copy(FKey, 0, MaxInt);
  SetLength(LKey, FHash.GetBlockSize);
  SetLength(TempBuffer1, FHash.GetBlockSize + Length(LBuffer));
  for I := Low(LKey) to High(LKey) do begin
    TempBuffer1[I] := LKey[I] xor CInnerPad;
  end;
  if Length(LBuffer) > 0 then
    Move(LBuffer[0], TempBuffer1[Length(LKey)], Length(LBuffer));

  FHash.Reset;
  FHash.Update(TempBuffer1);
  TempBuffer2 := FHash.GetDigest;

  SetLength(TempBuffer1, FHash.GetBlockSize + FHash.GetHashSize);
  for I := Low(LKey) to High(LKey) do begin
    TempBuffer1[I] := LKey[I] xor COuterPad;
  end;
  Move(TempBuffer2[0], TempBuffer1[Length(LKey)], Length(TempBuffer2));

  FHash.Reset;
  FHash.Update(TempBuffer1);
  Result := FHash.GetDigest;
end;

end.

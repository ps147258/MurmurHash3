object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 435
  ClientWidth = 625
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    625
    435)
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 45
    Height = 416
    Anchors = [akLeft, akTop, akBottom]
    BevelOuter = bvNone
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 2
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 416
    Width = 625
    Height = 19
    Panels = <
      item
        Width = 100
      end
      item
        Width = 100
      end
      item
        Width = 100
      end>
    ExplicitLeft = 184
    ExplicitTop = 392
    ExplicitWidth = 0
  end
  object Memo1: TMemo
    Left = 48
    Top = 0
    Width = 577
    Height = 416
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      'From Wikipedia, the free encyclopedia'
      
        'MurmurHash is a non-cryptographic hash function suitable for gen' +
        'eral hash-based lookup.[1][2][3] It was created by Austin Appleb' +
        'y in 2008[4] and, as of 8 January 2016,[5] is hosted on GitHub a' +
        'long with its test suite named SMHasher. It also exists in a num' +
        'ber of variants,[6] all of which have been released into the pub' +
        'lic domain. The name comes from two basic operations, multiply (' +
        'MU) and rotate (R), used in its inner loop.'
      ''
      
        'Unlike cryptographic hash functions, it is not specifically desi' +
        'gned to be difficult to reverse by an adversary, making it unsui' +
        'table for cryptographic purposes.'
      ''
      'Variants'
      'MurmurHash1'
      
        'The original MurmurHash was created as an attempt to make a fast' +
        'er function than Lookup3.[7] Although successful, it had not bee' +
        'n tested thoroughly and was not capable of providing 64-bit hash' +
        'es as in Lookup3. Its design would be later built upon in Murmur' +
        'Hash2, combining a multiplicative hash (similar to the Fowler'#8211'No' +
        'll'#8211'Vo hash function) with an Xorshift.'
      ''
      'MurmurHash2'
      
        'MurmurHash2[8] yields a 32- or 64-bit value. It comes in multipl' +
        'e variants, including some that allow incremental hashing and al' +
        'igned or neutral versions.'
      ''
      
        'MurmurHash2 (32-bit, x86)'#8212'The original version; contains a flaw ' +
        'that weakens collision in some cases.[9]'
      
        'MurmurHash2A (32-bit, x86)'#8212'A fixed variant using Merkle'#8211'Damgard ' +
        'construction. Slightly slower.'
      
        'CMurmurHash2A (32-bit, x86)'#8212'MurmurHash2A, but works incrementall' +
        'y.'
      
        'MurmurHashNeutral2 (32-bit, x86)'#8212'Slower, but endian- and alignme' +
        'nt-neutral.'
      
        'MurmurHashAligned2 (32-bit, x86)'#8212'Slower, but does aligned reads ' +
        '(safer on some platforms).'
      
        'MurmurHash64A (64-bit, x64)'#8212'The original 64-bit version. Optimiz' +
        'ed for 64-bit arithmetic.'
      
        'MurmurHash64B (64-bit, x86)'#8212'A 64-bit version optimized for 32-bi' +
        't platforms. It is not a true 64-bit hash due to insufficient mi' +
        'xing of the stripes.[10]'
      
        'The person who originally found the flaw[clarification needed] i' +
        'n MurmurHash2 created an unofficial 160-bit version of MurmurHas' +
        'h2 called MurmurHash2_160.[11]'
      ''
      'MurmurHash3'
      
        'The current version, completed April 3, 2011, is MurmurHash3,[12' +
        '][13] which yields a 32-bit or 128-bit hash value. When using 12' +
        '8-bits, the x86 and x64 versions do not produce the same values,' +
        ' as the algorithms are optimized for their respective platforms.' +
        ' MurmurHash3 was released alongside SMHasher, a hash function te' +
        'st suite.'
      ''
      'Implementations'
      
        'The canonical implementation is in C++, but there are efficient ' +
        'ports for a variety of popular languages, including Python,[14] ' +
        'C,[15] Go,[16] C#,[13][17] D,[18] Lua, Perl,[19] Ruby,[20] Rust,' +
        '[21][22] PHP,[23][24] Common Lisp,[25] Haskell,[26] Elm,[27] Clo' +
        'jure,[28] Scala,[29] Java,[30][31][32] Erlang,[33] Swift,[34] Ob' +
        'ject Pascal,[35] Kotlin,[36] JavaScript,[37], OCaml[38] and Micr' +
        'osoft Excel[39].'
      ''
      
        'It has been adopted into a number of open-source projects, most ' +
        'notably libstdc++ (ver 4.6), nginx (ver 1.0.1),[40] Rubinius,[41' +
        '] libmemcached (the C driver for Memcached),[42] npm (nodejs pac' +
        'kage manager),[43] maatkit,[44] Hadoop,[1] Kyoto Cabinet,[45] Ca' +
        'ssandra,[46][47] Solr,[48] vowpal wabbit,[49] Elasticsearch,[50]' +
        ' Guava,[51] Kafka,[52] and RedHat Virtual Data Optimizer (VDO).[' +
        '53]'
      ''
      'Vulnerabilities'
      
        'Hash functions can be vulnerable to collision attacks, where a u' +
        'ser can choose input data in such a way so as to intentionally c' +
        'ause hash collisions. Jean-Philippe Aumasson and Daniel J. Berns' +
        'tein were able to show that even implementations of MurmurHash u' +
        'sing a randomized seed are vulnerable to so-called HashDoS attac' +
        'ks.[54] With the use of differential cryptanalysis, they were ab' +
        'le to generate inputs that would lead to a hash collision. The a' +
        'uthors of the attack recommend using their own SipHash instead.'
      ''
      'Algorithm'
      'algorithm Murmur3_32 is'
      
        '    // Note: In this version, all arithmetic is performed with u' +
        'nsigned 32-bit integers.'
      
        '    //       In the case of overflow, the result is reduced modu' +
        'lo 232.'
      '    input: key, len, seed'
      ''
      '    c1 '#8592' 0xcc9e2d51'
      '    c2 '#8592' 0x1b873593'
      '    r1 '#8592' 15'
      '    r2 '#8592' 13'
      '    m '#8592' 5'
      '    n '#8592' 0xe6546b64'
      ''
      '    hash '#8592' seed'
      ''
      '    for each fourByteChunk of key do'
      '        k '#8592' fourByteChunk'
      ''
      '        k '#8592' k '#215' c1'
      '        k '#8592' k ROL r1'
      '        k '#8592' k '#215' c2'
      ''
      '        hash '#8592' hash XOR k'
      '        hash '#8592' hash ROL r2'
      '        hash '#8592' (hash '#215' m) + n'
      ''
      '    with any remainingBytesInKey do'
      '        remainingBytes '#8592' SwapToLittleEndian(remainingBytesInKey)'
      
        '        // Note: Endian swapping is only necessary on big-endian' +
        ' machines.'
      
        '        //       The purpose is to place the meaningful digits t' +
        'owards the low end of the value,'
      
        '        //       so that these digits have the greatest potentia' +
        'l to affect the low range digits'
      
        '        //       in the subsequent multiplication.  Consider tha' +
        't locating the meaningful digits'
      
        '        //       in the high range would produce a greater effec' +
        't upon the high digits of the'
      
        '        //       multiplication, and notably, that such high dig' +
        'its are likely to be discarded'
      
        '        //       by the modulo arithmetic under overflow.  We do' +
        'n'#39't want that.'
      ''
      '        remainingBytes '#8592' remainingBytes '#215' c1'
      '        remainingBytes '#8592' remainingBytes ROL r1'
      '        remainingBytes '#8592' remainingBytes '#215' c2'
      ''
      '        hash '#8592' hash XOR remainingBytes'
      ''
      '    hash '#8592' hash XOR len'
      ''
      '    hash '#8592' hash XOR (hash >> 16)'
      '    hash '#8592' hash '#215' 0x85ebca6b'
      '    hash '#8592' hash XOR (hash >> 13)'
      '    hash '#8592' hash '#215' 0xc2b2ae35'
      '    hash '#8592' hash XOR (hash >> 16)'
      'A sample C implementation follows (for little-endian CPUs):'
      ''
      'static inline uint32_t murmur_32_scramble(uint32_t k) {'
      '    k *= 0xcc9e2d51;'
      '    k = (k << 15) | (k >> 17);'
      '    k *= 0x1b873593;'
      '    return k;'
      '}'
      
        'uint32_t murmur3_32(const uint8_t* key, size_t len, uint32_t see' +
        'd)'
      '{'
      #9'uint32_t h = seed;'
      '    uint32_t k;'
      '    /* Read in groups of 4. */'
      '    for (size_t i = len >> 2; i; i--) {'
      
        '        // Here is a source of differing results across endianne' +
        'sses.'
      '        // A swap here has no effects on hash properties though.'
      '        memcpy(&k, key, sizeof(uint32_t));'
      '        key += sizeof(uint32_t);'
      '        h ^= murmur_32_scramble(k);'
      '        h = (h << 13) | (h >> 19);'
      '        h = h * 5 + 0xe6546b64;'
      '    }'
      '    /* Read the rest. */'
      '    k = 0;'
      '    for (size_t i = len & 3; i; i--) {'
      '        k <<= 8;'
      '        k |= key[i - 1];'
      '    }'
      
        '    // A swap is *not* necessary here because the preceding loop' +
        ' already'
      
        '    // places the low bytes in the low places according to whate' +
        'ver endianness'
      
        '    // we use. Swaps only apply when the memory is copied in a c' +
        'hunk.'
      '    h ^= murmur_32_scramble(k);'
      '    /* Finalize. */'
      #9'h ^= len;'
      #9'h ^= h >> 16;'
      #9'h *= 0x85ebca6b;'
      #9'h ^= h >> 13;'
      #9'h *= 0xc2b2ae35;'
      #9'h ^= h >> 16;'
      #9'return h;'
      '}'
      'Tests'
      
        'Test string'#9'Seed value'#9'Hash value (hexadecimal)'#9'Hash value (deci' +
        'mal)'
      '0x00000000'#9'0x00000000'#9'0'
      '0x00000001'#9'0x514E28B7'#9'1,364,076,727'
      '0xffffffff'#9'0x81F16F39'#9'2,180,083,513'
      'test'#9'0x00000000'#9'0xba6bd213'#9'3,127,628,307'
      'test'#9'0x9747b28c'#9'0x704b81dc'#9'1,883,996,636'
      'Hello, world!'#9'0x00000000'#9'0xc0363e43'#9'3,224,780,355'
      'Hello, world!'#9'0x9747b28c'#9'0x24884CBA'#9'612,912,314'
      
        'The quick brown fox jumps over the lazy dog'#9'0x00000000'#9'0x2e4ff72' +
        '3'#9'776,992,547'
      
        'The quick brown fox jumps over the lazy dog'#9'0x9747b28c'#9'0x2FA826C' +
        'D'#9'799,549,133'
      'See also'
      'Non-cryptographic hash functions'
      'References'
      
        ' "Hadoop in Java". Hbase.apache.org. 24 July 2011. Archived from' +
        ' the original on 12 January 2012. Retrieved 13 January 2012.'
      ' Chouza et al.'
      
        ' "Couceiro et al" (PDF) (in Portuguese). p. 14. Retrieved 13 Jan' +
        'uary 2012.'
      
        ' Tanjent (tanjent) wrote,3 March 2008 13:31:00. "MurmurHash firs' +
        't announcement". Tanjent.livejournal.com. Retrieved 13 January 2' +
        '012.'
      
        ' Austin Appleby. "SMHasher". Github.com. Retrieved 23 September ' +
        '2024.'
      
        ' "MurmurHash2-160". Simonhf.wordpress.com. 25 September 2010. Re' +
        'trieved 13 January 2012.'
      ' "MurmurHash1". GitHub. Retrieved 12 January 2019.'
      ' "MurmurHash2 on Github". GitHub.'
      ' "MurmurHash2Flaw". GitHub. Retrieved 15 January 2019.'
      
        ' "MurmurHash3 (see note on MurmurHash2_x86_64)". GitHub. Retriev' +
        'ed 15 January 2019.'
      
        ' "MurmurHash2_160". 25 September 2010. Retrieved 12 January 2019' +
        '.'
      ' "MurmurHash3 on Github". GitHub.'
      
        ' Horvath, Adam (10 August 2012). "MurMurHash3, an ultra fast has' +
        'h algorithm for C# / .NET".'
      ' "pyfasthash in Python". Retrieved 13 January 2012.'
      ' "C implementation in qLibc by Seungyoung Kim". GitHub.'
      ' "murmur3 in Go". GitHub.'
      
        ' Landman, Davy. "Davy Landman in C#". Landman-code.blogspot.com.' +
        ' Retrieved 13 January 2012.'
      
        ' "std.digest.murmurhash - D Programming Language". dlang.org. Re' +
        'trieved 5 November 2016.'
      
        ' "Toru Maesaka in Perl". metacpan.org. Retrieved 13 January 2012' +
        '.'
      
        ' Yuki Kurihara (16 October 2014). "Digest::MurmurHash". GitHub.c' +
        'om. Retrieved 18 March 2015.'
      ' "stusmall/murmur3". GitHub. Retrieved 29 November 2015.'
      ' "owengombas/murmurs". GitHub. Retrieved 13 June 2025.'
      
        ' "PHP userland implementation of MurmurHash3". github.com. Retri' +
        'eved 18 December 2017.'
      ' "PHP 8.1 with MurmurHash3 support".'
      ' "tarballs_are_good / murmurhash3". Retrieved 7 February 2015.'
      ' "Haskell". Hackage.haskell.org. Retrieved 13 January 2012.')
    ScrollBars = ssBoth
    TabOrder = 0
    WordWrap = False
    OnChange = Memo1Change
    OnKeyPress = Memo1KeyPress
    OnMouseDown = Memo1MouseDown
    OnMouseMove = Memo1MouseMove
  end
end

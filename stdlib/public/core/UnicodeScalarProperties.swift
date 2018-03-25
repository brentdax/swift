//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2017 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//
// Exposes advanced properties of Unicode.Scalar defined by the Unicode
// Standard.
//===----------------------------------------------------------------------===//

import SwiftShims

extension Unicode.Scalar {

  /// A value that provides access to properties of a Unicode scalar that are
  /// defined by the Unicode standard.
  public struct Properties {
    internal init(_scalar: Unicode.Scalar) {
      // We convert the value to the underlying UChar32 type here and store it
      // in that form to make calling the ICU APIs cleaner below.
      self._value = __swift_stdlib_UChar32(bitPattern: _scalar._value)

      // Likewise, we cache the UTF-16 encoding of the scalar for a few of the
      // properties that require treating it like a string (e.g., case
      // mappings).
      let utf16 = _scalar.utf16
      self._utf16Length = utf16.count
      self._utf16 = (utf16[0], _utf16Length > 1 ? utf16[1] : 0)
    }

    internal var _value: __swift_stdlib_UChar32
    internal var _utf16: (UTF16.CodeUnit, UTF16.CodeUnit)
    internal var _utf16Length: Int
  }

  /// A value that provides access to properties of the Unicode scalar that are
  /// defined by the Unicode standard.
  public var properties: Properties {
    return Properties(_scalar: self)
  }
}

/// Boolean properties that are defined by the Unicode Standard (i.e., not
/// ICU-specific).
extension Unicode.Scalar.Properties {

  @_transparent
  internal func _hasBinaryProperty(
    _ property: __swift_stdlib_UProperty
  ) -> Bool {
    return __swift_stdlib_u_hasBinaryProperty(_value, property) != 0
  }

  /// A Boolean property indicating whether the scalar is alphabetic.
  ///
  /// Alphabetic scalars are the primary units of alphabets and/or syllabaries.
  ///
  /// This property corresponds to the `Alphabetic` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isAlphabetic: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_ALPHABETIC)
  }

  /// A Boolean property indicating whether the scalar is an ASCII character
  /// commonly used for the representation of hexadecimal numbers.
  ///
  /// The only scalars for which this property is true are:
  ///
  /// * U+0030...U+0039: DIGIT ZERO...DIGIT NINE
  /// * U+0041...U+0046: LATIN CAPITAL LETTER A...LATIN CAPITAL LETTER F
  /// * U+0061...U+0066: LATIN SMALL LETTER A...LATIN SMALL LETTER F
  ///
  /// This property corresponds to the `ASCII_Hex_Digit` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isASCIIHexDigit: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_ASCII_HEX_DIGIT)
  }

  /// A Boolean property indicating whether the scalar is a format control
  /// character that has a specific function in the Unicode Bidrectional
  /// Algorithm.
  ///
  /// This property corresponds to the `Bidi_Control` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isBidiControl: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_BIDI_CONTROL)
  }

  /// A Boolean property indicating whether the scalar is mirrored in
  /// bidirectional text.
  ///
  /// This property corresponds to the `Bidi_Mirrored` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isBidiMirrored: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_BIDI_MIRRORED)
  }

  /// A Boolean property indicating whether the scalar is a punctuation
  /// symbol explicitly called out as a dash in the Unicode Standard or a
  /// compatibility equivalent.
  ///
  /// This property corresponds to the `Dash` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isDash: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_DASH)
  }

  /// A Boolean property indicating whether the scalar is a default-ignorable
  /// code point.
  ///
  /// Default-ignorable code points are those that should be ignored by default
  /// in rendering (unless explicitly supported). They have no visible glyph or
  /// advance width in and of themselves, although they may affect the display,
  /// positioning, or adornment of adjacent or surrounding characters.
  ///
  /// This property corresponds to the `Default_Ignorable_Code_Point` property
  /// in the [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isDefaultIgnorableCodePoint: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_DEFAULT_IGNORABLE_CODE_POINT)
  }

  /// A Boolean property indicating whether the scalar is deprecated.
  ///
  /// Scalars are never removed from the Unicode Standard, but the usage of
  /// deprecated scalars is strongly discouraged.
  ///
  /// This property corresponds to the `Deprecated` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isDeprecated: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_DEPRECATED)
  }

  /// A Boolean property indicating whether the scalar is a diacritic.
  ///
  /// Diacritics are scalars that linguistically modify the meaning of another
  /// scalar to which they apply. Scalars for which this property is true are
  /// frequently, but not always, combining marks or modifiers.
  ///
  /// This property corresponds to the `Diacritic` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isDiacritic: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_DIACRITIC)
  }

  /// A Boolean property indicating whether the scalar's principal function is
  /// to extend the value or shape of a preceding alphabetic scalar.
  ///
  /// Typical extenders are length and iteration marks.
  ///
  /// This property corresponds to the `Extender` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isExtender: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_EXTENDER)
  }

  /// A Boolean property indicating whether the scalar is excluded from
  /// composition when performing Unicode normalization.
  ///
  /// This property corresponds to the `Full_Composition_Exclusion` property in
  /// the [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isFullCompositionExclusion: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_FULL_COMPOSITION_EXCLUSION)
  }

  /// A Boolean property indicating whether the scalar is a grapheme base.
  ///
  /// A grapheme base can be thought of as a space-occupying glyph above or
  /// below which other non-spacing modifying glyphs can be applied. For
  /// example, when the character `é` is represented in NFD form, the grapheme
  /// base is "e" (U+0065 LATIN SMALL LETTER E) and it is followed by a single
  /// grapheme extender, U+0301 COMBINING ACUTE ACCENT.
  ///
  /// The set of scalars for which `isGraphemeBase` is true is disjoint by
  /// definition from the set for which `isGraphemeExtend` is true.
  ///
  /// This property corresponds to the `Grapheme_Base` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isGraphemeBase: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_GRAPHEME_BASE)
  }

  /// A Boolean property indicating whether the scalar is a grapheme extender.
  ///
  /// A grapheme extender can be thought of primarily as a non-spacing glyph
  /// that is applied above or below another glyph.
  ///
  /// The set of scalars for which `isGraphemeExtend` is true is disjoint by
  /// definition from the set for which `isGraphemeBase` is true.
  ///
  /// This property corresponds to the `Grapheme_Extend` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isGraphemeExtend: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_GRAPHEME_EXTEND)
  }

  /// A Boolean property indicating whether the scalar is one that is commonly
  /// used for the representation of hexadecimal numbers or a compatibility
  /// equivalent.
  ///
  /// This property is true for all scalars for which `isASCIIHexDigit` is true
  /// as well as for their CJK halfwidth and fullwidth variants.
  ///
  /// This property corresponds to the `Hex_Digit` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isHexDigit: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_HEX_DIGIT)
  }

  /// A Boolean property indicating whether the scalar is one which is
  /// recommended to be allowed to appear in a non-starting position in a
  /// programming language identifier.
  ///
  /// Applications that store identifiers in NFKC normalized form should instead
  /// use `isXIDContinue` to check whether a scalar is a valid identifier
  /// character.
  ///
  /// This property corresponds to the `ID_Continue` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isIDContinue: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_ID_CONTINUE)
  }

  /// A Boolean property indicating whether the scalar is one which is
  /// recommended to be allowed to appear in a starting position in a
  /// programming language identifier.
  ///
  /// Applications that store identifiers in NFKC normalized form should instead
  /// use `isXIDStart` to check whether a scalar is a valid identifier
  /// character.
  ///
  /// This property corresponds to the `ID_Start` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isIDStart: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_ID_START)
  }

  /// A Boolean property indicating whether the scalar is considered to be a
  /// CJKV (Chinese, Japanese, Korean, and Vietnamese) or other siniform
  /// (Chinese writing-related) ideograph.
  ///
  /// This property roughly defines the class of "Chinese characters" and does
  /// not include characters of other logographic scripts such as Cuneiform or
  /// Egyptian Hieroglyphs
  ///
  /// This property corresponds to the `Ideographic` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isIdeographic: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_IDEOGRAPHIC)
  }

  /// A Boolean property indicating whether the scalar is an ideographic
  /// description character that determines how the two ideographic characters
  /// or ideographic description sequences that follow it are to be combined to
  /// form a single character.
  ///
  /// Ideographic description characters are technically printable characters,
  /// but advanced rendering engines may use them to approximate ideographs that
  /// are otherwise unrepresentable.
  ///
  /// This property corresponds to the `IDS_Binary_Operator` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isIDSBinaryOperator: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_IDS_BINARY_OPERATOR)
  }

  /// A Boolean property indicating whether the scalar is an ideographic
  /// description character that determines how the three ideographic characters
  /// or ideographic description sequences that follow it are to be combined to
  /// form a single character.
  ///
  /// Ideographic description characters are technically printable characters,
  /// but advanced rendering engines may use them to approximate ideographs that
  /// are otherwise unrepresentable.
  ///
  /// This property corresponds to the `IDS_Trinary_Operator` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isIDSTrinaryOperator: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_IDS_TRINARY_OPERATOR)
  }

  /// A Boolean property indicating whether the scalar is a format control
  /// character that has a specific function in controlling cursive joining and
  /// ligation.
  ///
  /// There are two scalars for which this property is true:
  ///
  /// * When U+200C ZERO WIDTH NON-JOINER is inserted between two characters, it
  ///   directs the rendering engine to render them separately/disconnected when
  ///   it might otherwise render them as a ligature. For example, a rendering
  ///   engine might display "fl" in English as a connected glyph; inserting the
  ///   zero width non-joiner would force them to be rendered as disconnected
  ///   glyphs.
  ///
  /// * When U+200D ZERO WIDTH JOINER is inserted between two characters, it
  ///   directs the rendering engine to render them as a connected glyph when it
  ///   would otherwise render them independently. The zero width joiner is also
  ///   used to construct complex emoji from sequences of base emoji characters.
  ///   For example, "family" emoji are created by joining sequences of man,
  ///   woman, and child emoji with the zero width joiner.
  ///
  /// This property corresponds to the `Join_Control` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isJoinControl: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_JOIN_CONTROL)
  }

  /// A Boolean property indicating whether the scalar requires special handling
  /// for operations involving ordering, such as sorting and searching.
  ///
  /// This property applies to a small number of spacing vowel letters occurring
  /// in some Southeast Asian scripts like Thai and Lao, which use a visual
  /// order display model. Such letters are stored in text ahead of
  /// syllable-initial consonants.
  ///
  /// This property corresponds to the `Logical_Order_Exception` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isLogicalOrderException: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_LOGICAL_ORDER_EXCEPTION)
  }

  /// A Boolean property indicating whether the scalar's letterform is
  /// considered lowercase.
  ///
  /// This property corresponds to the `Lowercase` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isLowercase: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_LOWERCASE)
  }

  /// A Boolean property indicating whether the scalar is one that naturally
  /// appears in mathematical contexts.
  ///
  /// The set of scalars for which this property is true includes mathematical
  /// operators and symbols as well as specific Greek and Hebrew letter
  /// variants that are categorized as symbols. Notably, it does _not_ contain
  /// the standard digits or Latin/Greek letter blocks; instead, it contains the
  /// mathematical Latin, Greek, and Arabic letters and numbers defined in the
  /// Supplemental Multilingual Plane.
  ///
  /// This property corresponds to the `Math` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isMath: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_MATH)
  }

  /// A Boolean property indicating whether the scalar is permanently reserved
  /// for internal use.
  ///
  /// This property corresponds to the `Noncharacter_Code_Point` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isNoncharacterCodePoint: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_NONCHARACTER_CODE_POINT)
  }

  /// A Boolean property indicating whether the scalar is one that is used in
  /// writing to surround quoted text.
  ///
  /// This property corresponds to the `Quotation_Mark` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isQuotationMark: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_QUOTATION_MARK)
  }

  /// A Boolean property indicating whether the scalar is a radical component of
  /// CJK characters, Tangut characters, or Yi syllables.
  ///
  /// These scalars are often the components of ideographic description
  /// sequences, as defined by the `isIDSBinaryOperator` and
  /// `isIDSTrinaryOperator` properties.
  ///
  /// This property corresponds to the `Radical` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isRadical: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_RADICAL)
  }

  /// A Boolean property indicating whether the scalar has a "soft dot" that
  /// disappears when a diacritic is placed over the scalar.
  ///
  /// For example, "i" is soft dotted because the dot disappears when adding an
  /// accent mark, as in "í".
  ///
  /// This property corresponds to the `Soft_Dotted` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isSoftDotted: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_SOFT_DOTTED)
  }

  /// A Boolean property indicating whether the scalar is a punctuation symbol
  /// that typically marks the end of a textual unit.
  ///
  /// This property corresponds to the `Terminal_Punctuation` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isTerminalPunctuation: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_TERMINAL_PUNCTUATION)
  }

  /// A Boolean property indicating whether the scalar is one of the unified
  /// CJK ideographs in the Unicode Standard.
  ///
  /// This property is false for CJK punctuation and symbols, as well as for
  /// compatibility ideographs (which canonically decompose to unified
  /// ideographs).
  ///
  /// This property corresponds to the `Unified_Ideograph` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isUnifiedIdeograph: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_UNIFIED_IDEOGRAPH)
  }

  /// A Boolean property indicating whether the scalar's letterform is
  /// considered uppercase.
  ///
  /// This property corresponds to the `Uppercase` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isUppercase: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_UPPERCASE)
  }

  /// A Boolean property indicating whether the scalar is a whitespace
  /// character.
  ///
  /// This property is true for scalars that are spaces, separator characters,
  /// and other control characters that should be treated as whitespace for the
  /// purposes of parsing text elements.
  ///
  /// This property corresponds to the `White_Space` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isWhitespace: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_WHITE_SPACE)
  }

  /// A Boolean property indicating whether the scalar is one which is
  /// recommended to be allowed to appear in a non-starting position in a
  /// programming language identifier, with adjustments made for NFKC normalized
  /// form.
  ///
  /// The set of scalars `[:XID_Continue:]` closes the set `[:ID_Continue:]`
  /// under NFKC normalization by removing any scalars whose normalized form is
  /// not of the form `[:ID_Continue:]*`.
  ///
  /// This property corresponds to the `XID_Continue` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isXIDContinue: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_XID_CONTINUE)
  }

  /// A Boolean property indicating whether the scalar is one which is
  /// recommended to be allowed to appear in a starting position in a
  /// programming language identifier, with adjustments made for NFKC normalized
  /// form.
  ///
  /// The set of scalars `[:XID_Start:]` closes the set `[:ID_Start:]` under
  /// NFKC normalization by removing any scalars whose normalized form is not of
  /// the form `[:ID_Start:] [:ID_Continue:]*`.
  ///
  /// This property corresponds to the `XID_Start` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isXIDStart: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_XID_START)
  }

  /// A Boolean property indicating whether the scalar is a punctuation mark
  /// that generally marks the end of a sentence.
  ///
  /// This property corresponds to the `Sentence_Terminal` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isSentenceTerminal: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_S_TERM)
  }

  /// A Boolean property indicating whether the scalar is a variation selector.
  ///
  /// Variation selectors allow rendering engines that support them to choose
  /// different glyphs to display for a particular code point.
  ///
  /// This property corresponds to the `Variation_Selector` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isVariationSelector: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_VARIATION_SELECTOR)
  }

  /// A Boolean property indicating whether the scalar is recommended to have
  /// syntactic usage in patterns represented in source code.
  ///
  /// This property corresponds to the `Pattern_Syntax` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isPatternSyntax: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_PATTERN_SYNTAX)
  }

  /// A Boolean property indicating whether the scalar is recommended to be
  /// treated as whitespace when parsing patterns represented in source code.
  ///
  /// This property corresponds to the `Pattern_White_Space` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isPatternWhitespace: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_PATTERN_WHITE_SPACE)
  }

  /// A Boolean property indicating whether the scalar is considered to be
  /// either lowercase, uppercase, or titlecase.
  ///
  /// Though similar in name, this property is _not_ equivalent to
  /// `changesWhenCaseMapped`. The set of scalars for which `isCased` is true is
  /// a superset of those for which `changesWhenCaseMapped` is true. An example
  /// of scalars that only have `isCased` as true are the Latin small capitals
  /// that are used by the International Phonetic Alphabet. These letters have a
  /// case but do not change when they are mapped to any of the other cases.
  ///
  /// This property corresponds to the `Cased` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isCased: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_CASED)
  }

  /// A Boolean property indicating whether the scalar is ignored for casing
  /// purposes.
  ///
  /// This property corresponds to the `Case_Ignorable` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isCaseIgnorable: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_CASE_IGNORABLE)
  }

  /// A Boolean property indicating whether the scalar is one whose normalized
  /// form is not stable under a `toLowercase` mapping.
  ///
  /// This property corresponds to the `Changes_When_Lowercased` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var changesWhenLowercased: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_CHANGES_WHEN_LOWERCASED)
  }

  /// A Boolean property indicating whether the scalar is one whose normalized
  /// form is not stable under a `toUppercase` mapping.
  ///
  /// This property corresponds to the `Changes_When_Uppercased` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var changesWhenUppercased: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_CHANGES_WHEN_UPPERCASED)
  }

  /// A Boolean property indicating whether the scalar is one whose normalized
  /// form is not stable under a `toTitlecase` mapping.
  ///
  /// This property corresponds to the `Changes_When_Titlecased` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var changesWhenTitlecased: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_CHANGES_WHEN_TITLECASED)
  }

  /// A Boolean property indicating whether the scalar is one whose normalized
  /// form is not stable under case folding.
  ///
  /// This property corresponds to the `Changes_When_Casefolded` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var changesWhenCaseFolded: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_CHANGES_WHEN_CASEFOLDED)
  }

  /// A Boolean property indicating whether the scalar may change when it
  /// undergoes a case mapping.
  ///
  /// For any scalar `s`, it holds by definition that
  ///
  /// ```
  /// s.changesWhenCaseMapped = s.changesWhenLowercased ||
  ///                           s.changesWhenUppercased ||
  ///                           s.changesWhenTitlecased
  /// ```
  ///
  /// This property corresponds to the `Changes_When_Casemapped` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var changesWhenCaseMapped: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_CHANGES_WHEN_CASEMAPPED)
  }

  /// A Boolean property indicating whether the scalar is one that is not
  /// identical to its NFKC case-fold mapping.
  ///
  /// This property corresponds to the `Changes_When_NFKC_Casefolded` property
  /// in the [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var changesWhenNFKCCaseFolded: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_CHANGES_WHEN_NFKC_CASEFOLDED)
  }

  /// A Boolean property indicating whether the scalar has an emoji
  /// presentation, whether or not it is the default.
  ///
  /// This property is true for scalars that are rendered as emoji by default
  /// and also for scalars that have a non-default emoji rendering when followed
  /// by U+FE0F VARIATION SELECTOR-16. This includes some scalars that are not
  /// typically considered to be emoji:
  ///
  /// ```
  /// let sunglasses: Unicode.Scalar = "😎"
  /// let dollar: Unicode.Scalar = "$"
  /// let zero: Unicode.Scalar = "0"
  ///
  /// print(sunglasses.isEmoji)
  /// // Prints "true"
  /// print(dollar.isEmoji)
  /// // Prints "false"
  /// print(zero.isEmoji)
  /// // Prints "true"
  /// ```
  ///
  /// The final result is true because the ASCII digits have non-default emoji
  /// presentations; some platforms render these with an alternate appearance.
  ///
  /// Because of this behavior, testing `isEmoji` alone on a single scalar is
  /// insufficient to determine if a unit of text is rendered as an emoji; a
  /// correct test requires inspecting multiple scalars in a `Character`. In
  /// addition to checking whether the base scalar has `isEmoji == true`, you
  /// must also check its default presentation (see `isEmojiPresentation`) and
  /// determine whether it is followed by a variation selector that would modify
  /// the presentation.
  ///
  /// This property corresponds to the `Emoji` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isEmoji: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_EMOJI)
  }

  /// A Boolean property indicating whether the scalar is one that should be
  /// rendered with an emoji presentation, rather than a text presentation, by
  /// default.
  ///
  /// Scalars that have emoji presentation by default can be followed by
  /// U+FE0E VARIATION SELECTOR-15 to request the text presentation of the
  /// scalar instead. Likewise, scalars that default to text presentation can
  /// be followed by U+FE0F VARIATION SELECTOR-16 to request the emoji
  /// presentation.
  ///
  /// This property corresponds to the `Emoji_Presentation` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isEmojiPresentation: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_EMOJI_PRESENTATION)
  }

  /// A Boolean property indicating whether the scalar is one that can modify
  /// a base emoji that precedes it.
  ///
  /// The Fitzpatrick skin types are examples of emoji modifiers; they change
  /// the appearance of the preceding emoji base (that is, a scalar for which
  /// `isEmojiModifierBase` is true) by rendering it with a different skin tone.
  ///
  /// This property corresponds to the `Emoji_Modifier` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isEmojiModifier: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_EMOJI_MODIFIER)
  }

  /// A Boolean property indicating whether the scalar is one whose appearance
  /// can be changed by an emoji modifier that follows it.
  ///
  /// This property corresponds to the `Emoji_Modifier_Base` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var isEmojiModifierBase: Bool {
    return _hasBinaryProperty(__swift_stdlib_UCHAR_EMOJI_MODIFIER_BASE)
  }
}

extension Unicode {

  /// A version of the Unicode Standard represented by its `major.minor`
  /// components.
  public typealias Version = (major: Int, minor: Int)
}

extension Unicode.Scalar.Properties {

  /// The earliest version of the Unicode Standard in which the scalar was
  /// assigned.
  ///
  /// This value will be nil for code points that have not yet been assigned.
  ///
  /// This property corresponds to the `Age` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var age: Unicode.Version? {
    var versionInfo: __swift_stdlib_UVersionInfo = (0, 0, 0, 0)
    withUnsafeMutablePointer(to: &versionInfo.0) { versionInfoPointer in
      __swift_stdlib_u_charAge(_value, versionInfoPointer)
    }
    guard versionInfo.0 != 0 else { return nil }
    return (major: Int(versionInfo.0), Int(versionInfo.1))
  }
}

extension Unicode {

  /// The most general classification of a Unicode scalar.
  ///
  /// The general category of a scalar is its "first-order, most usual
  /// categorization". It does not attempt to cover multiple uses of some
  /// scalars, such as the use of letters to represent Roman numerals.
  public enum GeneralCategory {

    /// An uppercase letter.
    ///
    /// This value corresponds to the category `Uppercase_Letter` (abbreviated
    /// `Lu`) in the
    /// [Unicode Standard](https://unicode.org/reports/tr44/#General_Category_Values).
    case uppercaseLetter

    /// A lowercase letter.
    ///
    /// This value corresponds to the category `Lowercase_Letter` (abbreviated
    /// `Ll`) in the
    /// [Unicode Standard](https://unicode.org/reports/tr44/#General_Category_Values).
    case lowercaseLetter

    /// A digraph character whose first part is uppercase.
    ///
    /// This value corresponds to the category `Titlecase_Letter` (abbreviated
    /// `Lt`) in the
    /// [Unicode Standard](https://unicode.org/reports/tr44/#General_Category_Values).
    case titlecaseLetter

    /// A modifier letter.
    ///
    /// This value corresponds to the category `Modifier_Letter` (abbreviated
    /// `Lm`) in the
    /// [Unicode Standard](https://unicode.org/reports/tr44/#General_Category_Values).
    case modifierLetter

    /// Other letters, including syllables and ideographs.
    ///
    /// This value corresponds to the category `Other_Letter` (abbreviated
    /// `Lo`) in the
    /// [Unicode Standard](https://unicode.org/reports/tr44/#General_Category_Values).
    case otherLetter

    /// A non-spacing combining mark with zero advance width (abbreviated Mn).
    ///
    /// This value corresponds to the category `Nonspacing_Mark` (abbreviated
    /// `Mn`) in the
    /// [Unicode Standard](https://unicode.org/reports/tr44/#General_Category_Values).
    case nonspacingMark

    /// A spacing combining mark with positive advance width.
    ///
    /// This value corresponds to the category `Spacing_Mark` (abbreviated `Mc`)
    /// in the
    /// [Unicode Standard](https://unicode.org/reports/tr44/#General_Category_Values).
    case spacingMark

    /// An enclosing combining mark.
    ///
    /// This value corresponds to the category `Enclosing_Mark` (abbreviated
    /// `Me`) in the
    /// [Unicode Standard](https://unicode.org/reports/tr44/#General_Category_Values).
    case enclosingMark

    /// A decimal digit.
    ///
    /// This value corresponds to the category `Decimal_Number` (abbreviated
    /// `Nd`) in the
    /// [Unicode Standard](https://unicode.org/reports/tr44/#General_Category_Values).
    case decimalNumber

    /// A letter-like numeric character.
    ///
    /// This value corresponds to the category `Letter_Number` (abbreviated
    /// `Nl`) in the
    /// [Unicode Standard](https://unicode.org/reports/tr44/#General_Category_Values).
    case letterNumber

    /// A numeric character of another type.
    ///
    /// This value corresponds to the category `Other_Number` (abbreviated `No`)
    /// in the
    /// [Unicode Standard](https://unicode.org/reports/tr44/#General_Category_Values).
    case otherNumber

    /// A connecting punctuation mark, like a tie.
    ///
    /// This value corresponds to the category `Connector_Punctuation`
    /// (abbreviated `Pc`) in the
    /// [Unicode Standard](https://unicode.org/reports/tr44/#General_Category_Values).
    case connectorPunctuation

    /// A dash or hyphen punctuation mark.
    ///
    /// This value corresponds to the category `Dash_Punctuation` (abbreviated
    /// `Pd`) in the
    /// [Unicode Standard](https://unicode.org/reports/tr44/#General_Category_Values).
    case dashPunctuation

    /// An opening punctuation mark of a pair.
    ///
    /// This value corresponds to the category `Open_Punctuation` (abbreviated
    /// `Ps`) in the
    /// [Unicode Standard](https://unicode.org/reports/tr44/#General_Category_Values).
    case openPunctuation

    /// A closing punctuation mark of a pair.
    ///
    /// This value corresponds to the category `Close_Punctuation` (abbreviated
    /// `Pe`) in the
    /// [Unicode Standard](https://unicode.org/reports/tr44/#General_Category_Values).
    case closePunctuation

    /// An initial quotation mark.
    ///
    /// This value corresponds to the category `Initial_Punctuation`
    /// (abbreviated `Pi`) in the
    /// [Unicode Standard](https://unicode.org/reports/tr44/#General_Category_Values).
    case initialPunctuation

    /// A final quotation mark.
    ///
    /// This value corresponds to the category `Final_Punctuation` (abbreviated
    /// `Pf`) in the
    /// [Unicode Standard](https://unicode.org/reports/tr44/#General_Category_Values).
    case finalPunctuation

    /// A punctuation mark of another type.
    ///
    /// This value corresponds to the category `Other_Punctuation` (abbreviated
    /// `Po`) in the
    /// [Unicode Standard](https://unicode.org/reports/tr44/#General_Category_Values).
    case otherPunctuation

    /// A symbol of mathematical use.
    ///
    /// This value corresponds to the category `Math_Symbol` (abbreviated `Sm`)
    /// in the
    /// [Unicode Standard](https://unicode.org/reports/tr44/#General_Category_Values).
    case mathSymbol

    /// A currency sign.
    ///
    /// This value corresponds to the category `Currency_Symbol` (abbreviated
    /// `Sc`) in the
    /// [Unicode Standard](https://unicode.org/reports/tr44/#General_Category_Values).
    case currencySymbol

    /// A non-letterlike modifier symbol.
    ///
    /// This value corresponds to the category `Modifier_Symbol` (abbreviated
    /// `Sk`) in the
    /// [Unicode Standard](https://unicode.org/reports/tr44/#General_Category_Values).
    case modifierSymbol

    /// A symbol of another type.
    ///
    /// This value corresponds to the category `Other_Symbol` (abbreviated
    /// `So`) in the
    /// [Unicode Standard](https://unicode.org/reports/tr44/#General_Category_Values).
    case otherSymbol

    /// A space character of non-zero width.
    ///
    /// This value corresponds to the category `Space_Separator` (abbreviated
    /// `Zs`) in the
    /// [Unicode Standard](https://unicode.org/reports/tr44/#General_Category_Values).
    case spaceSeparator

    /// A line separator, which is specifically (and only) U+2028 LINE
    /// SEPARATOR.
    ///
    /// This value corresponds to the category `Line_Separator` (abbreviated
    /// `Zl`) in the
    /// [Unicode Standard](https://unicode.org/reports/tr44/#General_Category_Values).
    case lineSeparator

    /// A paragraph separator, which is specifically (and only) U+2029 PARAGRAPH
    /// SEPARATOR.
    ///
    /// This value corresponds to the category `Paragraph_Separator`
    /// (abbreviated `Zp`) in the
    /// [Unicode Standard](https://unicode.org/reports/tr44/#General_Category_Values).
    case paragraphSeparator

    /// A C0 or C1 control code.
    ///
    /// This value corresponds to the category `Control` (abbreviated `Cc`) in
    /// the
    /// [Unicode Standard](https://unicode.org/reports/tr44/#General_Category_Values).
    case control

    /// A format control character.
    ///
    /// This value corresponds to the category `Format` (abbreviated `Cf`) in
    /// the
    /// [Unicode Standard](https://unicode.org/reports/tr44/#General_Category_Values).
    case format

    /// A surrogate code point.
    ///
    /// This value corresponds to the category `Surrogate` (abbreviated `Cs`) in
    /// the
    /// [Unicode Standard](https://unicode.org/reports/tr44/#General_Category_Values).
    case surrogate

    /// A private-use character.
    ///
    /// This value corresponds to the category `Private_Use` (abbreviated `Co`)
    /// in the
    /// [Unicode Standard](https://unicode.org/reports/tr44/#General_Category_Values).
    case privateUse

    /// A reserved unassigned code point or a non-character.
    ///
    /// This value corresponds to the category `Unassigned` (abbreviated `Cn`)
    /// in the
    /// [Unicode Standard](https://unicode.org/reports/tr44/#General_Category_Values).
    case unassigned

    internal init(rawValue: __swift_stdlib_UCharCategory) {
      switch rawValue {
      case __swift_stdlib_U_UNASSIGNED: self = .unassigned
      case __swift_stdlib_U_UPPERCASE_LETTER: self = .uppercaseLetter
      case __swift_stdlib_U_LOWERCASE_LETTER: self = .lowercaseLetter
      case __swift_stdlib_U_TITLECASE_LETTER: self = .titlecaseLetter
      case __swift_stdlib_U_MODIFIER_LETTER: self = .modifierLetter
      case __swift_stdlib_U_OTHER_LETTER: self = .otherLetter
      case __swift_stdlib_U_NON_SPACING_MARK: self = .nonspacingMark
      case __swift_stdlib_U_ENCLOSING_MARK: self = .enclosingMark
      case __swift_stdlib_U_COMBINING_SPACING_MARK: self = .spacingMark
      case __swift_stdlib_U_DECIMAL_DIGIT_NUMBER: self = .decimalNumber
      case __swift_stdlib_U_LETTER_NUMBER: self = .letterNumber
      case __swift_stdlib_U_OTHER_NUMBER: self = .otherNumber
      case __swift_stdlib_U_SPACE_SEPARATOR: self = .spaceSeparator
      case __swift_stdlib_U_LINE_SEPARATOR: self = .lineSeparator
      case __swift_stdlib_U_PARAGRAPH_SEPARATOR: self = .paragraphSeparator
      case __swift_stdlib_U_CONTROL_CHAR: self = .control
      case __swift_stdlib_U_FORMAT_CHAR: self = .format
      case __swift_stdlib_U_PRIVATE_USE_CHAR: self = .privateUse
      case __swift_stdlib_U_SURROGATE: self = .surrogate
      case __swift_stdlib_U_DASH_PUNCTUATION: self = .dashPunctuation
      case __swift_stdlib_U_START_PUNCTUATION: self = .openPunctuation
      case __swift_stdlib_U_END_PUNCTUATION: self = .closePunctuation
      case __swift_stdlib_U_CONNECTOR_PUNCTUATION: self = .connectorPunctuation
      case __swift_stdlib_U_OTHER_PUNCTUATION: self = .otherPunctuation
      case __swift_stdlib_U_MATH_SYMBOL: self = .mathSymbol
      case __swift_stdlib_U_CURRENCY_SYMBOL: self = .currencySymbol
      case __swift_stdlib_U_MODIFIER_SYMBOL: self = .modifierSymbol
      case __swift_stdlib_U_OTHER_SYMBOL: self = .otherSymbol
      case __swift_stdlib_U_INITIAL_PUNCTUATION: self = .initialPunctuation
      case __swift_stdlib_U_FINAL_PUNCTUATION: self = .finalPunctuation
      default: fatalError("Unknown general category \(rawValue)")
      }
    }
  }
}

extension Unicode.Scalar.Properties {

  /// The general category (most usual classification) of the scalar.
  ///
  /// This property corresponds to the `General_Category` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var generalCategory: Unicode.GeneralCategory {
    let rawValue = __swift_stdlib_UCharCategory(
      UInt32(__swift_stdlib_u_getIntPropertyValue(
        _value, __swift_stdlib_UCHAR_GENERAL_CATEGORY)))
    return Unicode.GeneralCategory(rawValue: rawValue)
  }
}

/// Executes a block that will attempt to store text in the memory owned by the
/// given string storage object, returning the length of the text.
///
/// The closure is assumed to return an `Int32` value (the convention of ICU's C
/// functions) that is equal to the length of the string being stored. If the
/// storage object is not large enough to hold the string, it is replaced by one
/// that is exactly the required size and the closure is executed one more time
/// to populate it.
@_inlineable
@_versioned
internal func _expandingStorageIfNeeded<
  CodeUnit: UnsignedInteger & FixedWidthInteger
>(
  _ storage: inout _SwiftStringStorage<CodeUnit>,
  body: (_SwiftStringStorage<CodeUnit>) throws -> Int32
) rethrows -> Int {
  let z = try body(storage)
  let correctSize = Int(z)
  if correctSize > storage.capacity {
    // If the buffer wasn't large enough, replace it with one that is the
    // correct size and execute the closure again.
    storage = _SwiftStringStorage<CodeUnit>.create(
      capacity: correctSize,
      count: correctSize)
    return Int(try body(storage))
  } else {
    // Otherwise, the buffer has been populated; update its count to the correct
    // value.
    storage.count = correctSize
    return correctSize
  }
}

extension Unicode.Scalar.Properties {

  internal func _scalarName(
    _ choice: __swift_stdlib_UCharNameChoice
  ) -> String? {
    let initialCapacity = 256

    var storage = _SwiftStringStorage<UTF8.CodeUnit>.create(
      capacity: initialCapacity,
      count: 0)
    var err = __swift_stdlib_U_ZERO_ERROR

    let correctSize = _expandingStorageIfNeeded(&storage) { storage in
      return storage.start.withMemoryRebound(
        to: Int8.self,
        capacity: storage.capacity
      ) { storagePtr in
        err = __swift_stdlib_U_ZERO_ERROR
        return __swift_stdlib_u_charName(
          _value, choice, storagePtr, Int32(storage.capacity), &err)
      }
    }

    guard err.isSuccess && correctSize > 0 else {
      return nil
    }
    return String(_storage: storage)
  }

  /// The published name of the scalar.
  ///
  /// Some scalars, such as control characters, do not have a value for this
  /// property in the UCD. For such scalars, this property will be nil.
  ///
  /// This property corresponds to the `Name` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var name: String? {
    return _scalarName(__swift_stdlib_U_UNICODE_CHAR_NAME)
  }

  /// The normative formal alias of the scalar, or nil if it has no alias.
  ///
  /// The name of a scalar is immutable and never changed in future versions of
  /// the Unicode Standard. The `nameAlias` property is provided to issue
  /// corrections if a name was issued erroneously. For example, the `name` of
  /// U+FE18 is "PRESENTATION FORM FOR VERTICAL RIGHT WHITE LENTICULAR BRAKCET"
  /// (note that "BRACKET" is misspelled). The `nameAlias` property then
  /// contains the corrected name.
  ///
  /// This property corresponds to the `Name_Alias` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var nameAlias: String? {
    return _scalarName(__swift_stdlib_U_CHAR_NAME_ALIAS)
  }
}

extension Unicode.Scalar.Properties {

  /// The lowercase mapping of the scalar.
  ///
  /// This property is a `String` because some mappings may transform a single
  /// scalar into multiple scalars. For example, the character "İ" (U+0130
  /// LATIN CAPITAL LETTER I WITH DOT ABOVE) becomes two scalars (U+0069 LATIN
  /// SMALL LETTER I, U+0307 COMBINING DOT ABOVE) when converted to lowercase.
  ///
  /// This property corresponds to the `Lowercase_Mapping` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var lowercaseMapping: String {
    let initialCapacity = 1

    var storage = _SwiftStringStorage<UTF16.CodeUnit>.create(
      capacity: initialCapacity,
      count: 0)

    _ = _expandingStorageIfNeeded(&storage) { storage in
      var utf16 = _utf16
      return withUnsafePointer(to: &utf16.0) { utf16Pointer in
        var err = __swift_stdlib_U_ZERO_ERROR
        let correctSize = __swift_stdlib_u_strToLower(
          storage.start, Int32(storage.capacity),
          utf16Pointer, Int32(_utf16Length), "", &err)
        guard err.isSuccess ||
              err == __swift_stdlib_U_BUFFER_OVERFLOW_ERROR else {
          fatalError(
            "u_strToLower: Unexpected error lowercasing Unicode scalar.")
        }
        return correctSize
      }
    }
    return String(_storage: storage)
  }

  /// The titlecase mapping of the scalar.
  ///
  /// This property is a `String` because some mappings may transform a single
  /// scalar into multiple scalars. For example, the ligature "ﬁ" (U+FB01 LATIN
  /// SMALL LIGATURE FI) becomes "Fi" (U+0046 LATIN CAPITAL LETTER F, U+0069
  /// LATIN SMALL LETTER I) when converted to titlecase.
  ///
  /// This property corresponds to the `Titlecase_Mapping` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var titlecaseMapping: String {
    let initialCapacity = 1

    var storage = _SwiftStringStorage<UTF16.CodeUnit>.create(
      capacity: initialCapacity,
      count: 0)

    _ = _expandingStorageIfNeeded(&storage) { storage in
      var utf16 = _utf16
      return withUnsafePointer(to: &utf16.0) { utf16Pointer in
        var err = __swift_stdlib_U_ZERO_ERROR
        let correctSize = __swift_stdlib_u_strToTitle(
          storage.start, Int32(storage.capacity),
          utf16Pointer, Int32(_utf16Length), nil, "", &err)
        guard err.isSuccess ||
              err == __swift_stdlib_U_BUFFER_OVERFLOW_ERROR else {
          fatalError(
            "u_strToTitle: Unexpected error titlecasing Unicode scalar.")
        }
        return correctSize
      }
    }
    return String(_storage: storage)
  }

  /// The uppercase mapping of the scalar.
  ///
  /// This property is a `String` because some mappings may transform a single
  /// scalar into multiple scalars. For example, the German letter "ß" (U+00DF
  /// LATIN SMALL LETTER SHARP S) becomes "SS" (U+0053 LATIN CAPITAL LETTER S,
  /// U+0053 LATIN CAPITAL LETTER S) when converted to uppercase.
  ///
  /// This property corresponds to the `Uppercase_Mapping` property in the
  /// [Unicode Standard](http://www.unicode.org/versions/latest/).
  public var uppercaseMapping: String {
    let initialCapacity = 1

    var storage = _SwiftStringStorage<UTF16.CodeUnit>.create(
      capacity: initialCapacity,
      count: 0)

    _ = _expandingStorageIfNeeded(&storage) { storage in
      var utf16 = _utf16
      return withUnsafePointer(to: &utf16.0) { utf16Pointer in
        var err = __swift_stdlib_U_ZERO_ERROR
        let correctSize = __swift_stdlib_u_strToUpper(
          storage.start, Int32(storage.capacity),
          utf16Pointer, Int32(_utf16Length), "", &err)
        guard err.isSuccess ||
              err == __swift_stdlib_U_BUFFER_OVERFLOW_ERROR else {
          fatalError(
            "u_strToUpper: Unexpected error uppercasing Unicode scalar.")
        }
        return correctSize
      }
    }
    return String(_storage: storage)
  }
}

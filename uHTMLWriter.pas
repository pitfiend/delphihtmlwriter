unit uHTMLWriter;

interface

uses
  SysUtils, HTMLWriterUtils, Classes, Generics.Collections;
{$REGION 'License'}
{
  ***** BEGIN LICENSE BLOCK *****
  * Version: MPL 1.1
  *
  * The contents of this file are subject to the Mozilla Public License Version
  * 1.1 (the "License"); you may not use this file except in compliance with
  * the License. You may obtain a copy of the License at
  * http://www.mozilla.org/MPL/
  *
  * Software distributed under the License is distributed on an "AS IS" basis,
  * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
  * for the specific language governing rights and limitations under the
  * License.
  *
  * The Original Code is Delphi HTMLWriter
  *
  * The Initial Developer of the Original Code is
  * Nick Hodges
  *
  * Portions created by the Initial Developer are Copyright (C) 2010
  * the Initial Developer. All Rights Reserved.
  *
  * Contributor(s):
  *
  * ***** END LICENSE BLOCK *****
  }
{$ENDREGION}

type
{$REGION 'Documentation'}
  /// <summary>A class for creating HTML.   THTMLWriter uses the fluent interface. It can be used to create either
  /// complete HTML documents or chunks of HTML. By using the fluent interface, you can link together number of methods
  /// to create a complete document.</summary>
  /// <remarks>
  /// <para>THTMLWriter is very method heavy, but relatively code light. Most of the code simply ends up calling
  /// the  AddTag  method. The closing tags are tracked in a  TStack&lt;string&gt;  class.</para>
  /// <para>Most methods begin with either "Open" or "Add". Methods that start with "Open" will
  /// add  &lt;tag  to the HTML stream, leaving it ready for the addition of attributes or other content. The
  /// system will automatically close the tag when necessary.</para>
  /// <para>Methods that start with "Add" will normally take paramenters and then add content within a complete tag
  /// pair. For example, a call toAddBoldText('blah') will result in  &lt;b&gt;blah&lt;/b&gt;  being added to
  /// the HTML stream.</para>
  /// <para>Some things to note:</para>
  /// <list type="bullet">
  /// <item>Any tag that is opened will need to be closed via  CloseTag</item>
  /// <item>Any tag that is added via a  AddXXXX  call will close itself.</item>
  /// <item>The rule to follow: Close what you open. Additions take care of themselves.</item>
  /// <item>As a general rule, THTMLWriter will raise an exception if a tag is placed somewhere that doesn't make
  /// sense.</item>
  /// <item>Certain tags like  &lt;meta&gt;  and  &lt;base&gt;  can only be added inside
  /// at  &lt;head&gt;  tag.</item>
  /// <item>Tags such as  &lt;td&gt;,  &lt;tr&gt;  can only be added inside of
  /// a  &lt;table&gt;  tag.</item>
  /// <item>The same is true for list items inside lists.</item>
  /// </list>
  /// </remarks>
{$ENDREGION}
  THTMLWriter = class(TInterfacedObject, IGetHTML, ILoadSave)
  private
    FHTML: TStringBuilder;
    FClosingTags: TStackofStrings;
    FCurrentTagName: string;
    FTagState: TTagStates;
    FTableState: TTableStates;
    FParent: THTMLWriter;
    FCanHaveAttributes: TCanHaveAttributes;
    function AddFormattedText(aString: string; aFormatType: TFormatType): THTMLWriter;
    function OpenFormatTag(aFormatType: TFormatType; aCanAddAttributes: TCanHaveAttributes = chaCannotHaveAttributes): THTMLWriter;
    function AddHeadingText(aString: string; aHeadingType: THeadingType): THTMLWriter;
{$REGION 'In Tag Type Methods'}
    function InHeadTag: Boolean;
    function InBodyTag: Boolean;
    function InCommentTag: Boolean;
    function InSlashOnlyTag: Boolean;
    function TagIsOpen: Boolean;
    function InFormTag: Boolean;
    function InFieldSetTag: Boolean;
    function InListTag: Boolean;
    function InTableTag: Boolean;
    function InTableRowTag: Boolean;
    function TableIsOpen: Boolean;
    function InFrameSetTag: Boolean;
    function InMapTag: Boolean;
    function InObjectTag: Boolean;
{$ENDREGION}
    procedure IsDeprecatedTag(aName: string; aVersion: integer);


{$REGION 'Close and Clean Methods'}
    function CloseBracket: THTMLWriter;
    procedure CleanUpTagState;
    procedure CloseTheTag;
{$ENDREGION}
{$REGION 'Check Methods'}
    procedure CheckInHeadTag;
    procedure CheckInCommentTag;
    procedure CheckInListTag;
    procedure CheckInFormTag;
    procedure CheckInObjectTag;
    procedure CheckInFieldSetTag;
    procedure CheckInTableRowTag;
    procedure CheckInTableTag;
    procedure CheckInFramesetTag;
    procedure CheckInMapTag;
    procedure CheckBracketOpen(aString: string);
    procedure CheckCurrentTagIsHTMLTag;
{$ENDREGION}
    procedure PushClosingTagOnStack(aCloseTagType: TCloseTagType; aString: string = '');
    function GetAttribute(const Name, Value: string): THTMLWriter;
   
  public
{$REGION 'Constructors'}
{$REGION 'Documentation'}
    /// <summary>Creates an instance of THTMLWriter by passing in any arbitrary tag. Use this constructur if you want to create a chunk of HTML code not associated with a document.</summary>
    /// <param name="aTagName">The text for the tag you are creating. For instance, if you want to create a &lt;span&gt; tag, you should pass 'span' as the value</param>
    /// <param name="aCloseTagType">Determines the type of the tag being opened upon creation</param>
    /// <param name="aCanAddAttributes">Indicates if the tag should be allowed to have attributes. For instance, normally the &lt;b&gt; doesn't have attributes. Set this to False if you want to ensure that the tag will not have any attributes.</param>
    /// <exception cref="EHTMLWriterEmptyTagException">raised if an empty tag is passed as the aTagName parameter</exception>
    /// <seealso cref="CreateDocument">The CreateDocument constructor</seealso>
{$ENDREGION}
    constructor Create(aTagName: string; aCloseTagType: TCloseTagType = ctNormal; aCanAddAttributes: TCanHaveAttributes = chaCanHaveAttributes);

    /// <summary>The CreateDocument constructor will create a standard HTML document.</summary>
    constructor CreateDocument; overload;
    constructor CreateDocument(aDocType: THTMLDocType); overload;
    destructor Destroy; override;
{$ENDREGION}
    function AddTag(aString: string; aCloseTagType: TCloseTagType = ctNormal; aCanAddAttributes: TCanHaveAttributes = chaCanHaveAttributes): THTMLWriter;
{$REGION 'Main Section Methods'}
    /// <summary>Opens a&lt;head&gt; tag to the document.  </summary>
    function OpenHead: THTMLWriter;
{$REGION 'Documentation'}
    /// <summary>Opens a &lt;meta&gt; tag.</summary>
    /// <exception cref="EHeadTagRequiredHTMLException">Raised if an attempt is made  to call this method
    /// when not inside a &lt;head&gt; tag.</exception>
    /// <remarks>Note that this method can only be called from within &lt;head&gt; tag.   If it is called from
    /// anywhere else, it will raise an exception.</remarks>
{$ENDREGION}
    function OpenMeta: THTMLWriter;
{$REGION 'Documentation'}
    /// <summary>Opens a &lt;base /&gt; tag.</summary>
    /// <exception cref="EHeadTagRequiredHTMLException">Raised if this tag is added outside of the &lt;head&gt;
    /// tag.</exception>
    /// <remarks>This tag will always be closed with the '/&gt;' tag. In addition, this tag can only be added inside of
    /// a &lt;head&gt; tag.</remarks>
{$ENDREGION}
    function OpenBase: THTMLWriter;
    function OpenBaseFont: THTMLWriter;
    /// <summary>Adds a &lt;base /&gt; tag to the HTML.</summary>
    /// <remarks>Note:   this method can only be called inside an open &lt;head&gt; tag.</remarks>
    function AddBase(aTarget: TTargetType; aFrameName: string = ''): THTMLWriter; overload;
    function AddBase(aHREF: string): THTMLWriter; overload;
    /// <summary>Opens a &lt;title&gt; tag.</summary>
    function OpenTitle: THTMLWriter;
{$REGION 'Documentation'}
    /// <summary>Adds a &lt;title&gt; tag including the passed in text.</summary>
    /// <param name="aTitleText">The text to be placed inside the &lt;title&gt;&lt;/title&gt; tag</param>
    /// <remarks>There is no need to close this tag manually.   All "AddXXXX" methods close themselves.</remarks>
{$ENDREGION}
    function AddTitle(aTitleText: string): THTMLWriter;
    function AddMetaNamedContent(aName: string; aContent: string): THTMLWriter;

    /// <summary>Opens a &lt;body&gt; tag.</summary>
    function OpenBody: THTMLWriter;
{$ENDREGION}
{$REGION 'Text Block Methods'}
    /// <summary>Opens a &lt;p&gt; tag.  </summary>
    function OpenParagraph: THTMLWriter;
    /// <summary>Opens a &lt;p&gt; tag and gives it the passed in style="" attribute</summary>
    /// <param name="aStyle">The CSS-based text to be included in the style attribute for the &lt;p&gt; tag.</param>
    function OpenParagraphWithStyle(aStyle: string): THTMLWriter;
    function OpenParagraphWithID(aID: string): THTMLWriter;
    /// <summary>Opens a &lt;span&gt; tag.</summary>
    function OpenSpan: THTMLWriter;
    /// <summary>Opens a &lt;div&gt; tag.</summary>
    function OpenDiv: THTMLWriter;
    /// <summary>Opens a &lt;blockquote&gt; tag.</summary>
    function OpenBlockQuote: THTMLWriter;
{$REGION 'Documentation'}
    /// <summary>Adds the passed in text to the HTML inside of a &lt;p&gt; tag.</summary>
    /// <param name="aString">The text to be added into the &lt;p&gt; tag.</param>
{$ENDREGION}
    function AddParagraphText(aString: string): THTMLWriter;
{$REGION 'Documentation'}
    /// <summary>Adds the passed in text into a &lt;p&gt; tag and adds in the given Style attribute.</summary>
    /// <param name="aString">The text to be added within the &lt;p&gt; tag.</param>
    /// <param name="aStyle">The value for the Style attribute  to be added to the &lt;p&gt; tag.</param>
{$ENDREGION}
    function AddParagraphTextWithStyle(aString: string; aStyle: string): THTMLWriter;
    function AddParagraphTextWithID(aString: string; aID: string): THTMLWriter;

    /// <summary>Adds text inside of a &lt;span&gt; tag.</summary>
    /// <param name="aString">The text to be added inside of the &lt;span&gt;&lt;/span&gt; tag.</param>
    function AddSpanText(aString: string): THTMLWriter;
    function AddSpanTextWithStyle(aString: string; aStyle: string): THTMLWriter;
    function AddSpanTextWithID(aString: string; aID: string): THTMLWriter;

    /// <summary>Adds the passed in text to a &lt;div&lt;/div&gt; tag.</summary>
    /// <param name="aString">The text to be added inside teh &lt;div&gt;&lt;/div&gt; tag</param>
    function AddDivText(aString: string): THTMLWriter;
    function AddDivTextWithStyle(aString: string; aStyle: string): THTMLWriter;
    function AddDivTextWithID(aString: string; aID: string): THTMLWriter;
{$ENDREGION}
{$REGION 'General Formatting Methods'}
    /// <summary>Opens up a &lt;b&gt; tag. Once a tag is open, it can be added to as desired.</summary>
    function OpenBold: THTMLWriter;
    /// <summary>Opens up a &lt;i&gt; tag. Once a tag is open, it can be added to as desired.</summary>
    function OpenItalic: THTMLWriter;
    /// <summary>Opens up a &lt;u&gt; tag. Once a tag is open, it can be added to as desired.</summary>
    function OpenUnderline: THTMLWriter;
    /// <summary>Opens a &lt;em&gt; tag.</summary>
    function OpenEmphasis: THTMLWriter;
    /// <summary>Opens a &lt;strong&gt; tag.</summary>
    function OpenStrong: THTMLWriter;
    /// <summary>Opens a &lt;pre&gt; tag.</summary>
    function OpenPre: THTMLWriter;
    /// <summary>Opens a &lt;cite&gt; tag.</summary>
    function OpenCite: THTMLWriter;
    /// <summary>Opens a &lt;acronym&gt; tag.</summary>
    function OpenAcronym: THTMLWriter;
    /// <summary>Opens an &lt;abbr&gt; tag.</summary>
    function OpenAbbreviation: THTMLWriter;
    /// <summary>Opens an &lt;addr&gt; tag</summary>
    function OpenAddress: THTMLWriter;
    /// <summary>Opens a &lt;bdo&gt; tag.</summary>
    function OpenBDO: THTMLWriter;
    /// <summary>Opens a &lt;big&gt; tag.</summary>
    function OpenBig: THTMLWriter;
    /// <summary>Opens a &lt;center&gt; tag.</summary>
    function OpenCenter: THTMLWriter;
    /// <summary>Opens a &lt;code&gt; tag.</summary>
    function OpenCode: THTMLWriter;
    /// <summary>Opens a &lt;delete&gt; tag.</summary>
    function OpenDelete: THTMLWriter;
    /// <summary>Opens a &lt;dfn&gt; tag.</summary>
    function OpenDefinition: THTMLWriter;
    /// <summary>Opens a &lt;font&gt; tag.</summary>
    function OpenFont: THTMLWriter;
    /// <summary>Opens a &lt;kbd&gt; tag</summary>
    function OpenKeyboard: THTMLWriter;
    /// <summary>Opens a &lt;q&gt; tag.  </summary>
    function OpenQuotation: THTMLWriter;
    /// <summary>Opens a &lt;sample&gt; tag.</summary>
    function OpenSample: THTMLWriter;
    /// <summary>Opens a &lt;small&gt; tag.</summary>
    function OpenSmall: THTMLWriter;
    /// <summary>Opens a &lt;strike&gt; tag.</summary>
    function OpenStrike: THTMLWriter;
    /// <summary>Opens a &lt;tt&gt; tag.</summary>
    function OpenTeletype: THTMLWriter;
    /// <summary>Opens a &lt;var&gt; tag.</summary>
    function OpenVariable: THTMLWriter;
    /// <summary>Opens a &lt;ins&gt; tag.</summary>
    function OpenInsert: THTMLWriter;

    /// <summary>Adds a &lt;b&gt;&lt;/b&gt; containing the passed text</summary>
    /// <param name="aString">The text to be placed within the bold tag.</param>
    function AddBoldText(aString: string): THTMLWriter;
    /// <summary>Adds a &lt;i&gt;&lt;/i&gt; containing the passed text</summary>
    /// <param name="aString">The text to be placed within the italic tag.</param>
    function AddItalicText(aString: string): THTMLWriter;
    /// <summary>Adds a &lt;u&gt;&lt;/u&gt; containing the passed text</summary>
    /// <param name="aString">The text to be placed within the underline tag.</param>
    function AddUnderlinedText(aString: string): THTMLWriter;
    /// <summary>Adds the passed text inside of a &lt;em&gt;&lt;/em&gt; tag</summary>
    /// <param name="aString">The text to be added inside the Emphasis tag.</param>
    function AddEmphasisText(aString: string): THTMLWriter;
    /// <summary>Adds the passed in text to a &lt;strong&gt;&lt;/strong&gt; tag.</summary>
    /// <param name="aString">The text to be added to the strong tag.</param>
    function AddStrongText(aString: string): THTMLWriter;
    /// <summary>Adds the passed in text to a &lt;pre&gt;&lt;/pre&gt; tag</summary>
    /// <param name="aString">The text to be added inside a preformatted tag</param>
    function AddPreformattedText(aString: string): THTMLWriter;
    /// <summary>Adds the passed in text to a &lt;cite&lt;&lt;/cite&gt; tag</summary>
    /// <param name="aString">The text to be added inside the Citation tag.</param>
    function AddCitationText(aString: string): THTMLWriter;
    /// <summary>Adds the passed in text inside of a &lt;blockquote&gt;&lt;/blockquote&gt; tag.</summary>
    /// <param name="aString">The text to be included inside the block quote tag.</param>
    function AddBlockQuoteText(aString: string): THTMLWriter;
    /// <summary>Adds the passed in text to an &lt;acronym&gt;&lt;/acronym&gt; tag.</summary>
    /// <param name="aString">The string that will be included in the Acronym tag.</param>
    function AddAcronymText(aString: string): THTMLWriter;
    /// <summary>Adds the passed in text inside a &lt;abbr&gt;&lt;/abbr&gt; tag.</summary>
    /// <param name="aString">The text to be added inside the Abbreviation tag.</param>
    function AddAbbreviationText(aString: string): THTMLWriter;
    /// <summary>Adds the passed in text to a &lt;addr&gt;&lt;/addr&gt; tag.</summary>
    /// <param name="aString">The text to be included in the Address tag.</param>
    function AddAddressText(aString: string): THTMLWriter;
    /// <summary>Adds the passed in text to a &lt;bdo&gt;&lt;/bdo&gt; tag.</summary>
    /// <param name="aString">The text to be added inside the Bi-Directional tag.</param>
    function AddBDOText(aString: string): THTMLWriter;
    /// <summary>Adds the passed in text to a &lt;big&gt;&lt;/big&gt; tag.</summary>
    /// <param name="aString">The text to eb added to the Big tag.</param>
    function AddBigText(aString: string): THTMLWriter;
    /// <summary>Addes the passed in text to a &lt;center&gt;&lt;/center&gt; tag.</summary>
    /// <param name="aString">The text to be added to the Center tag.</param>
    function AddCenterText(aString: string): THTMLWriter;
    /// <summary>Adds the passed in text to a &lt;code&gt;&lt;/code&gt; tag.</summary>
    /// <param name="aString">The text to be added to the Code tag.</param>
    function AddCodeText(aString: string): THTMLWriter;
    /// <summary>Adds the passed in text to a &lt;delete&gt;&lt;/delete&gt; tag.</summary>
    /// <param name="aString">The text to be added to the Delete tag.</param>
    function AddDeleteText(aString: string): THTMLWriter;
    /// <summary>Adds the passed in text to a &lt;dfn&gt;&lt;/dfn&gt; tag.</summary>
    /// <param name="aString">The text to be added inside of the Definition tag.</param>
    function AddDefinitionText(aString: string): THTMLWriter;
    /// <summary>Adds the passed in text to a &lt;font&gt;&lt;/font&gt; tag.</summary>
    /// <param name="aString">The text to be included in the Font tag.</param>
    function AddFontText(aString: string): THTMLWriter;
    /// <summary>Adds the passed in text to a &lt;kbd&gt;&lt;/kbd&gt; tag.</summary>
    /// <param name="aString">The text to be added to the Keyboard tag.</param>
    function AddKeyboardText(aString: string): THTMLWriter;
    /// <summary>Adds the passed in text to a &lt;q&gt;&lt;/q&gt; tag</summary>
    /// <param name="aString">The string that will be included inside the quotation tag.</param>
    function AddQuotationText(aString: string): THTMLWriter;
    /// <summary>Adds the passed in text to a &lt;samp&gt;&lt;/samp&gt; tag.</summary>
    /// <param name="aString">The text to be inserted into the sample tag.</param>
    function AddSampleText(aString: string): THTMLWriter;
    /// <summary>Adds the passed in text to a &lt;small&gt;&lt;/small&gt; tag</summary>
    /// <param name="aString">The text to be included in a small tag.</param>
    function AddSmallText(aString: string): THTMLWriter;
    /// <summary>Adds the passed in text inside a &lt;strike&gt;&lt;/strike&gt; tag</summary>
    /// <param name="aString">The text to be included in the strike tag.</param>
    function AddStrikeText(aString: string): THTMLWriter;
    /// <summary>Adds the passed in text to a &lt;tt&gt;&lt;/tt&gt; tag.</summary>
    /// <param name="aString">The text to be added into the teletype tag.</param>
    function AddTeletypeText(aString: string): THTMLWriter;
    /// <summary>Adds the passed in text to a &lt;var&gt;&lt;/var&gt; tag</summary>
    /// <param name="aString">The text to be passed to the variable tag.</param>
    function AddVariableText(aString: string): THTMLWriter;
    /// <summary>Adds the passed in text to a &lt;ins&gt;&lt;/ins&gt; tag</summary>
    /// <param name="aString">The text to be passed to the insert tag.</param>
    function AddInsertText(aString: string): THTMLWriter;
{$ENDREGION}
{$REGION 'Heading Methods'}
    /// <summary>Opens a &lt;h1&gt; tag.</summary>
    function OpenHeading1: THTMLWriter;
    /// <summary>Opens a &lt;h2&gt; tag.</summary>
    function OpenHeading2: THTMLWriter;
    /// <summary>Opens a &lt;h3&gt; tag.</summary>
    function OpenHeading3: THTMLWriter;
    /// <summary>Opens a &lt;h4&gt; tag.</summary>
    function OpenHeading4: THTMLWriter;
    /// <summary>Opens a &lt;h5&gt; tag.</summary>
    function OpenHeading5: THTMLWriter;
    /// <summary>Opens a &lt;h6&gt; tag.</summary>
    function OpenHeading6: THTMLWriter;

    /// <summary>Inserts a &lt;h1&gt;&lt;/h1&gt; tag and places the given text in it.</summary>
    /// <param name="aString">The text to be placed inside the heading tag.</param>
    function AddHeading1Text(aString: string): THTMLWriter;
    /// <summary>Inserts a &lt;h2&gt;&lt;/h2&gt; tag and places the given text in it.</summary>
    /// <param name="aString">The text to be placed inside the heading tag.</param>
    function AddHeading2Text(aString: string): THTMLWriter;
    /// <summary>Inserts a &lt;h3&gt;&lt;/h3&gt; tag and places the given text in it.</summary>
    /// <param name="aString">The text to be placed inside the heading tag.</param>
    function AddHeading3Text(aString: string): THTMLWriter;
    /// <summary>Inserts a &lt;h4&gt;&lt;/h4&gt; tag and places the given text in it.</summary>
    /// <param name="aString">The text to be placed inside the heading tag.</param>
    function AddHeading4Text(aString: string): THTMLWriter;
    /// <summary>Inserts a &lt;h5&gt;&lt;/h5&gt; tag and places the given text in it.</summary>
    /// <param name="aString">The text to be placed inside the heading tag.</param>
    function AddHeading5Text(aString: string): THTMLWriter;
    /// <summary>Inserts a &lt;h6&gt;&lt;/h6&gt; tag and places the given text in it.</summary>
    /// <param name="aString">The text to be placed inside the heading tag.</param>
    function AddHeading6Text(aString: string): THTMLWriter;
{$ENDREGION}
{$REGION 'CSS Formatting Methods'}
    // CSS Formatting
    function AddStyle(aStyle: string): THTMLWriter;
    function AddClass(aClass: string): THTMLWriter;
    function AddID(aID: string): THTMLWriter;
{$ENDREGION}
{$REGION 'Miscellaneous Methods'}
{$REGION 'Documentation'}
    /// <summary>Adds an attribute to the current tag.   The tag must have its bracket open.  </summary>
    /// <param name="aString">The name of the attribute to be added.   If this is the only parameter passed in,
    /// then this string should contain the entire attribute string.</param>
    /// <param name="aValue">Optional parameter.   If this value is passed, then the first parameter become the
    /// <i>name</i>, and this one the <i>value</i>, in a <i>name=value</i> pair.</param>
    /// <exception cref="EHTMLWriterOpenTagRequiredException">Raised when this method is called on a tag that doesn't
    /// have it's bracket open.</exception>
{$ENDREGION}
    function AddAttribute(aString: string; aValue: string = ''): THTMLWriter;
{$REGION 'Documentation'}
    /// <summary>Adds a &lt;br /&gt; tag</summary>
    /// <param name="aClearValue">An optional parameter that determines if a clear attribute will be added.   The
    /// default value is not to include the clear attribute.</param>
    /// <param name="aUseCloseSlash">An optional parameter that determines if the tag will close with a /&gt;.
    /// The default is to do so.</param>
{$ENDREGION}
    function AddLineBreak(const aClearValue: TClearValue = cvNoValue; aUseEmptyTag: TIsEmptyTag = ietIsEmptyTag): THTMLWriter;
{$REGION 'Documentation'}
    /// <summary>Adds an &lt;hr&gt; tag to the HTML</summary>
    /// <param name="aAttributes">Attributes that should be added to the &lt;hr&gt; tag.</param>
    /// <param name="aUseEmptyTag">Determines if the &lt;hr&gt; tag should be rendered as &lt;hr /&gt;</param>
{$ENDREGION}
    function AddHardRule(const aAttributes: string = ''; aUseEmptyTag: TIsEmptyTag = ietIsEmptyTag): THTMLWriter;

    /// <summary>Adds a Carriage Return and a Line Feed to the HTML.</summary>
    function CRLF: THTMLWriter;

    /// <summary>Adds spaces to the HTML stream</summary>
    /// <param name="aNumberofSpaces">An integer indicating how many spaces should be added to the HTML.</param>
    function Indent(aNumberofSpaces: integer): THTMLWriter;
    /// <summary>Opens a &lt;comment&gt; tag</summary>
    function OpenComment: THTMLWriter;
{$REGION 'Documentation'}
    /// <summary>Adds any text to the HTML.  </summary>
    /// <param name="aString">The string to be added</param>
    /// <remarks>AddText will close the current tag and then add the text passed in the string parameter</remarks>
{$ENDREGION}
    function AddText(aString: string): THTMLWriter;
{$REGION 'Documentation'}
    /// <summary>AddRawText will inject the passed in string directly into the HTML.  </summary>
    /// <param name="aString">The text to be added to the HTML</param>
    /// <remarks>AddRawText  will not make any other changes to open tags or open brackets.   It just injects
    /// the passed text directly onto the HTML.</remarks>
{$ENDREGION}
    function AddRawText(aString: string): THTMLWriter;
{$REGION 'Documentation'}
    /// <summary>Returns a string containing the current HTML for the
    /// HTMLWriter</summary>
    /// <remarks>This property will return the HTML in whatever state it is
    /// in when called.   This may mean that brackets or even tags are
    /// open, attributes hanging undone, etc.  </remarks>
{$ENDREGION}
    function AsHTML: string;
    /// <summary>Adds a comment to the HTML stream</summary>
    /// <param name="aCommentText">The text to be added inside the comment</param>
    function AddComment(aCommentText: string): THTMLWriter;
    /// <summary>Opens a &lt;script&gt; tag</summary>
    function OpenScript: THTMLWriter;
    /// <summary>Adds the passed in script text to a &lt;script&gt;&lt;/script&gt; tag.</summary>
    /// <param name="aScriptText">The script text to be added inside the Script tag.</param>
    function AddScript(aScriptText: string): THTMLWriter;

    /// <summary>Opens a &lt;noscript&gt; tag</summary>
    function OpenNoScript: THTMLWriter;

    /// <summary>Opens a &lt;link /&gt; tag.</summary>
    function OpenLink: THTMLWriter;
{$ENDREGION}
{$REGION 'CloseTag methods'}
{$REGION 'Documentation'}
    /// <summary>Closes an open tag.</summary>
    /// <param name="aUseCRLF">Determines if CRLF should be added after the closing of the tag.</param>
    /// <exception cref="ETryingToCloseClosedTag">Raised if you try to close a tag when no tag is open.</exception>
{$ENDREGION}
    function CloseTag(aUseCRLF: TUseCRLFOptions = ucoNoCRLF): THTMLWriter;
    /// <summary>Closes an open comment tag.</summary>
    function CloseComment: THTMLWriter;
    /// <summary>Closes an open &lt;list&gt; tag</summary>
    function CloseList: THTMLWriter;
    /// <summary>Closes an open &lt;table&gt; tag.</summary>
    function CloseTable: THTMLWriter;
    /// <summary>Closes and open &lt;form&gt; tag.</summary>
    function CloseForm: THTMLWriter;
    /// <summary>Closes and open &lt;html&gt; tag.</summary>
    function CloseDocument: THTMLWriter;

    { TODO -oNick : Add more specialized close tags CloseTable, CloseList, etc. }
{$ENDREGION}
{$REGION 'Image Methods'}
    /// <summary>Opens in &lt;img&gt; tag.</summary>
    /// <remarks>This tag will always be closed by " /&gt;"</remarks>
    function OpenImage: THTMLWriter; overload;
    ///	<summary>Opens an &lt;img&gt; tag and adds the 'src' parameter.</summary>
    ///	<param name="aImageSource">The URL of the image to be displayed</param>
    function OpenImage(aImageSource: string): THTMLWriter; overload;
    function AddImage(aImageSource: string): THTMLWriter;
{$ENDREGION}
{$REGION 'Anchor Methods'}
    function OpenAnchor: THTMLWriter; overload;
    function OpenAnchor(aName: string): THTMLWriter; overload;
    function OpenAnchor(const aHREF: string; aText: string): THTMLWriter; overload;
    function AddAnchor(const aHREF: string; aText: string): THTMLWriter; overload;
{$ENDREGION}
{$REGION 'Table Support Methods'}
{$REGION 'Documentation'}
    /// <summary>Opens a &lt;table&gt; tag</summary>
    /// <remarks>You cannot use other table related tags (&lt;tr&gt;, &lt;td&gt;, etc.) until a &lt;table&gt; tag is
    /// open.</remarks>
{$ENDREGION}
    function OpenTable: THTMLWriter; overload;
    ///	<summary>Opens a &lt;table&gt; tag and adds the 'border' attribute</summary>
    function OpenTable(aBorder: integer): THTMLWriter; overload;
    function OpenTable(aBorder: integer; aCellPadding: integer): THTMLWriter; overload;
    function OpenTable(aBorder: integer; aCellPadding: integer; aCellSpacing: integer): THTMLWriter; overload;
    function OpenTable(aBorder: integer; aCellPadding: integer; aCellSpacing: integer; aWidth: THTMLWidth): THTMLWriter; overload;

    /// <summary>Opens a &lt;tr&gt; tag.</summary>
    function OpenTableRow: THTMLWriter;
    /// <summary>Opens a &lt;td&gt; tag.</summary>
    /// <remarks>This method can only be called when a &lt;tr&gt; tag is open.</remarks>
    function OpenTableData: THTMLWriter;
    {$REGION 'Documentation'}
    ///	<summary>Adds the given text inside of a &lt;td&gt; tag.</summary>
    ///	<exception cref="ENotInTableTagException">Raised when an attempt is made to add something in a table when the appropriate tag is not open.</exception>
    ///	<remarks>This tag can only be added while a table row &lt;tr&gt; tag is open. Otherwise, an exception is raised.</remarks>
    {$ENDREGION}
    function AddTableData(aText: string): THTMLWriter;
    function AddCaption(aCaption: string): THTMLWriter;

    {
      Additional Table support required:

      <th>
      <col>
      <colgroup>
      <thead>
      <tbody>
      <tfoot>

      }
{$ENDREGION}
{$REGION 'Form Methods'}
    function OpenForm(aActionURL: string = ''; aMethod: TFormMethod = fmGet): THTMLWriter;
    function OpenInput: THTMLWriter; overload;
    function OpenInput(aType: TInputType; aName: string = ''): THTMLWriter; overload;
    function OpenButton(aName: string): THTMLWriter;
    function OpenLabel: THTMLWriter; overload;
    function OpenLabel(aFor: string): THTMLWriter; overload;

    { TODO -oNick : Add all supporting tags to <form> }
    {
      <select>
      <optgroup>
      <option>
      <textarea>
      Need to check the HTML book to ensure that this is a complete list

      }
{$ENDREGION}
{$REGION 'FieldSet/Legend'}
    /// <summary>Opens a &lt;fieldset&gt; tag.</summary>
    function OpenFieldSet: THTMLWriter;

    /// <summary>Opens a &lt;legend&gt; tag.</summary>
    /// <remarks>This method will raise an exception if called outside of an open &lt;fieldset&gt; tag.</remarks>
    function OpenLegend: THTMLWriter;

    /// <summary>Adds the passed in text to a &lt;legend&gt;&lt;/legend&gt; tag</summary>
    /// <param name="aText">The text to be included in the Legend tag.</param>
    function AddLegend(aText: string): THTMLWriter;
{$ENDREGION}
{$REGION 'IFrame support'}
    /// <summary>Opens an &lt;iframe&gt; tag.</summary>
    function OpenIFrame: THTMLWriter; overload;

    /// <summary>Opens an &lt;iframe&gt; tag and adds a url parameter</summary>
    /// <param name="aURL">The value to be added with the url parameter.</param>
    function OpenIFrame(aURL: string): THTMLWriter; overload;
    function OpenIFrame(aURL: string; aWidth: THTMLWidth; aHeight: integer): THTMLWriter; overload;
    function AddIFrame(aURL: string; aAlternateText: string): THTMLWriter; overload;
    function AddIFrame(aURL: string; aAlternateText: string; aWidth: THTMLWidth; aHeight: integer): THTMLWriter; overload;
{$ENDREGION}
{$REGION 'List Methods'}

    ///	<summary>Opens an unordered list tag (&lt;ul&gt;)</summary>
    ///	<param name="aBulletShape">An optional parameter indicating the bullet type that the list should use.</param>
    ///	<seealso cref="TBulletShape">TBulletShape</seealso>
    function OpenUnorderedList(aBulletShape: TBulletShape = bsNone): THTMLWriter;
    {$REGION 'Documentation'}
    ///	<summary>Opens an ordered list tag (&lt;ol&gt;)</summary>
    ///	<param name="aNumberType">An optional parameter indicating the numbering type that the list should use.</param>
    ///	<seealso cref="TNumberType">TNumberType</seealso>
    {$ENDREGION}
    function OpenOrderedList(aNumberType: TNumberType = ntNone): THTMLWriter;
    ///	<summary>Opens a list item (&lt;li&gt;) inside of a list.</summary>
    function OpenListItem: THTMLWriter;
    ///	<summary>Adds a List item (&lt;li&gt;) with the given text</summary>
    ///	<param name="aText">The text to be added to the list item.</param>
    function AddListItem(aText: string): THTMLWriter;
{$ENDREGION}
{$REGION 'Storage Methods'}
    procedure LoadFromFile(const FileName: string); overload; virtual;
    procedure LoadFromFile(const FileName: string; Encoding: TEncoding); overload; virtual;
    procedure LoadFromStream(Stream: TStream); overload; virtual;
    procedure LoadFromStream(Stream: TStream; Encoding: TEncoding); overload; virtual;
    procedure SaveToFile(const FileName: string); overload; virtual;
    procedure SaveToFile(const FileName: string; Encoding: TEncoding); overload; virtual;
    procedure SaveToStream(Stream: TStream); overload; virtual;
    procedure SaveToStream(Stream: TStream; Encoding: TEncoding); overload; virtual;
{$ENDREGION}
    /// <summary>Opens a &lt;frameset&gt; tag.</summary>
    function OpenFrameset: THTMLWriter;
{$REGION 'Documentation'}
    /// <summary>Opens a &lt;frame&gt; tag.</summary>
    /// <exception cref="ENotInFrameSetHTMLException">Raised if this is called outside of a &lt;frameset&gt;
    /// tag.</exception>
{$ENDREGION}
    function OpenFrame: THTMLWriter;
    /// <summary>Opens a &lt;noframes&gt; tag.</summary>
    function OpenNoFrames: THTMLWriter;
    /// <summary>Opens a &lt;map /&gt; tag</summary>
    function OpenMap: THTMLWriter;
    /// <summary>Opens an &lt;area /&gt; tag</summary>
    function OpenArea: THTMLWriter;
    /// <summary>Opens an &lt;object&gt; tag</summary>
    function OpenObject: THTMLWriter;
    {$REGION 'Documentation'}
    ///	<summary>Opens a &lt;param&gt; tag</summary>
    ///	<param name="aName">The name for the parameter</param>
    ///	<param name="aValue">The value to be assigned to the paramter</param>
    ///	<remarks>This tag can only be used inside of an &lt;object&gt; tag.</remarks>
    {$ENDREGION}
    function OpenParam(aName: string; aValue: string = ''): THTMLWriter; // name parameter is required
{$REGION 'Documentation'}
    /// <summary>Opens a &lt;param&gt; tag</summary>
    /// <exception cref="ENotInObjectTagException">Raised if this method is called outside of an &lt;object&gt;
    /// tag</exception>
{$ENDREGION}
    property Attribute[const Name: string; const Value: string]: THTMLWriter read GetAttribute; default;

  end;

implementation

{ THTMLWriter }

function THTMLWriter.CloseBracket: THTMLWriter;
begin
  if (tsBracketOpen in FTagState) and (not InCommentTag) then
  begin
    FHTML := FHTML.Append(cCloseBracket);
    Include(FTagState, tsTagOpen);
    Exclude(FTagState, tsBracketOpen);
  end;
  Result := Self;
end;

function THTMLWriter.CloseComment: THTMLWriter;
begin
  CheckInCommentTag;
  Result := CloseTag;
end;

function THTMLWriter.CloseDocument: THTMLWriter;
begin
  CheckCurrentTagIsHTMLTag;
  Result := CloseTag;
end;

function THTMLWriter.CloseForm: THTMLWriter;
begin
  CheckInFormTag;
  Result := CloseTag;
end;

function THTMLWriter.CloseList: THTMLWriter;
begin
  CheckInListTag;
  Result := CloseTag;
end;

function THTMLWriter.CloseTable: THTMLWriter;
begin
  CheckInTableTag;
  Result := CloseTag;
end;

function THTMLWriter.CloseTag(aUseCRLF: TUseCRLFOptions = ucoNoCRLF): THTMLWriter;
begin
  if tsTagClosed in FTagState then
  begin
    raise ETryingToCloseClosedTag.Create(strClosingClosedTag);
  end;

  if (not InSlashOnlyTag) and (not InCommentTag) then
  begin
    CloseBracket;
  end;

  CloseTheTag;

  CleanUpTagState;

  Result := FParent;
  if aUseCRLF = ucoUseCRLF then
  begin
    Result.FHTML.Append(cCRLF);
  end;
end;

constructor THTMLWriter.Create(aTagName: string; aCloseTagType: TCloseTagType = ctNormal; aCanAddAttributes: TCanHaveAttributes = chaCanHaveAttributes);
begin
  if StringIsEmpty(aTagName) then
  begin
    raise EEmptyTagHTMLWriterException.Create(strTagNameRequired);
  end;
  FCurrentTagName := aTagName;
  FCanHaveAttributes := chaCanHaveAttributes;
  FHTML := TStringBuilder.Create;
  FHTML := FHTML.Append(cOpenBracket).Append(FCurrentTagName);
  FTagState := FTagState + [tsBracketOpen];
  FParent := Self;
  FClosingTags := TStackofStrings.Create;
  PushClosingTagOnStack(aCloseTagType, aTagName);
end;

constructor THTMLWriter.CreateDocument(aDocType: THTMLDocType);
begin

  inherited Create;
  CreateDocument;
  FHTML := FHTML.Insert(0, THTMLDocTypeStrings[aDocType]);
end;

function THTMLWriter.CRLF: THTMLWriter;
begin
  CloseBracket;
  FHTML.Append(cCRLF);
  Result := Self;
end;

constructor THTMLWriter.CreateDocument;
begin
  Create(cHTML, ctNormal, chaCanHaveAttributes);
end;

destructor THTMLWriter.Destroy;
begin
  FHTML.Free;
  FClosingTags.Free;
  inherited;
end;

function THTMLWriter.GetAttribute(const Name, Value: string): THTMLWriter;
begin
  Result := Self.AddAttribute(Name, Value);
end;

function THTMLWriter.InBodyTag: Boolean;
begin
  Result := tsInBodyTag in FTagState;
end;

function THTMLWriter.InCommentTag: Boolean;
begin
  Result := tsCommentOpen in FTagState;
end;

function THTMLWriter.Indent(aNumberofSpaces: integer): THTMLWriter;
var
  i: integer;
begin
  for i := 1 to aNumberofSpaces do
  begin
    FHTML.Append(cSpace);
  end;
  Result := Self;
end;

function THTMLWriter.InFieldSetTag: Boolean;
begin
  Result := tsInFieldSetTag in FTagState;
end;

function THTMLWriter.InFormTag: Boolean;
begin
  Result := tsInFormTag in FTagState;
end;

function THTMLWriter.TableIsOpen: Boolean;
begin
  Result := tsTableIsOpen in FTagState;
end;

function THTMLWriter.InFrameSetTag: Boolean;
begin
  Result := tsInFramesetTag in FTagState;
end;

function THTMLWriter.TagIsOpen: Boolean;
begin
  Result := tsTagOpen in FTagState;
end;

function THTMLWriter.InHeadTag: Boolean;
begin
  Result := tsInHeadTag in FTagState;
end;

function THTMLWriter.InListTag: Boolean;
begin
  Result := tsInListTag in FTagState;
end;

function THTMLWriter.InMapTag: Boolean;
begin
  Result := tsInMapTag in FTagState;
end;

function THTMLWriter.InObjectTag: Boolean;
begin
  Result := tsInObjectTag in FTagState;
end;

function THTMLWriter.InSlashOnlyTag: Boolean;
var
  PeekValue: string;
begin
  PeekValue := FClosingTags.Peek;
  Result := (PeekValue = TTagMaker.MakeSlashCloseTag);
end;

function THTMLWriter.InTableRowTag: Boolean;
begin
  Result := tsInTableRowTag in FTagState;
end;

function THTMLWriter.InTableTag: Boolean;
begin
  Result := tsInTableTag in FTagState;
end;

procedure THTMLWriter.IsDeprecatedTag(aName: string; aVersion: integer);
begin
  raise ETagIsDeprecated4HTMLWriterException.Create(Format('The %s tag is deprecated  in HTML %d.x.', [aName, aVersion]));
end;

function THTMLWriter.OpenBold: THTMLWriter;
begin
  Result := OpenFormatTag(ftBold);
end;

function THTMLWriter.OpenButton(aName: string): THTMLWriter;
begin
  CheckInFormTag;
  Result := AddTag(cButton).AddAttribute(cName, aName);
end;

function THTMLWriter.OpenCenter: THTMLWriter;
begin
  Result := OpenFormatTag(ftCenter);
end;

function THTMLWriter.OpenCite: THTMLWriter;
begin
  Result := OpenFormatTag(ftCitation);
end;

function THTMLWriter.OpenEmphasis: THTMLWriter;
begin
  Result := OpenFormatTag(ftEmphasis);
end;

function THTMLWriter.OpenFieldSet: THTMLWriter;
begin
  CheckInFormTag;
  Result := AddTag(cFieldSet);
  Result.FTagState := Result.FTagState + [tsInFieldSetTag];
end;

function THTMLWriter.OpenFont: THTMLWriter;
begin
  Result := OpenFormatTag(ftFont);
end;

function THTMLWriter.OpenForm(aActionURL: string = ''; aMethod: TFormMethod = fmGet): THTMLWriter;
begin
  Result := AddTag(cForm);
  if not StringIsEmpty(aActionURL) then
  begin
    Result := Result[cAction, aActionURL];
  end;
  if aMethod <> fmNone then
  begin
    Result := Result[cMethod, TFormMethodStrings[aMethod]]
  end;

  Result.FTagState := Result.FTagState + [tsInFormTag];
end;

function THTMLWriter.OpenFormatTag(aFormatType: TFormatType; aCanAddAttributes: TCanHaveAttributes = chaCannotHaveAttributes): THTMLWriter;
begin
  Result := AddTag(TFormatTypeStrings[aFormatType], ctNormal, chaCannotHaveAttributes);
end;

function THTMLWriter.OpenFrame: THTMLWriter;
begin
  CheckInFramesetTag;
  Result := AddTag(cFrame);
end;

function THTMLWriter.OpenFrameset: THTMLWriter;
begin
  Result := AddTag(cFrameSet);
  Include(Result.FTagState, tsInFramesetTag);
end;

function THTMLWriter.OpenHeading1: THTMLWriter;
begin
  Result := AddTag(THeadingTypeStrings[htHeading1]);
end;

function THTMLWriter.OpenHeading2: THTMLWriter;
begin
  Result := AddTag(THeadingTypeStrings[htHeading2]);
end;

function THTMLWriter.OpenHeading3: THTMLWriter;
begin
  Result := AddTag(THeadingTypeStrings[htHeading3]);
end;

function THTMLWriter.OpenHeading4: THTMLWriter;
begin
  Result := AddTag(THeadingTypeStrings[htHeading4]);
end;

function THTMLWriter.OpenHeading5: THTMLWriter;
begin
  Result := AddTag(THeadingTypeStrings[htHeading5]);
end;

function THTMLWriter.OpenHeading6: THTMLWriter;
begin
  Result := AddTag(THeadingTypeStrings[htHeading6]);
end;

function THTMLWriter.OpenImage: THTMLWriter;
begin
  Result := AddTag(cImage, ctEmpty);
end;

function THTMLWriter.OpenIFrame: THTMLWriter;
begin
  Result := AddTag(cIFrame);
end;

function THTMLWriter.OpenIFrame(aURL: string): THTMLWriter;
begin
  Result := OpenIFrame.AddAttribute(cSource, aURL);
end;

function THTMLWriter.OpenIFrame(aURL: string; aWidth: THTMLWidth; aHeight: integer): THTMLWriter;
begin
  Result := OpenIFrame(aURL).AddAttribute(aWidth.WidthString).AddAttribute(cHeight, IntToStr(aHeight));
end;

function THTMLWriter.OpenImage(aImageSource: string): THTMLWriter;
begin
  Result := AddTag(cImage, ctEmpty).AddAttribute(cSource, aImageSource);
end;

function THTMLWriter.OpenInput(aType: TInputType; aName: string = ''): THTMLWriter;
begin
  CheckInFormTag;
  Result := OpenInput.AddAttribute(cType, TInputTypeStrings[aType]);
  if StringIsNotEmpty(aName) then
  begin
    Result := Result[cName, aName];
  end;
end;

function THTMLWriter.OpenInsert: THTMLWriter;
begin
  Result := OpenFormatTag(ftInsert);
end;

function THTMLWriter.AddImage(aImageSource: string): THTMLWriter;
begin
  Result := OpenImage(aImageSource).CloseTag;
end;

function THTMLWriter.OpenInput: THTMLWriter;
begin
  CheckInFormTag;
  Result := AddTag(cInput, ctEmpty);
end;

function THTMLWriter.AddInsertText(aString: string): THTMLWriter;
begin
  Result := AddFormattedText(aString, ftInsert);
end;

function THTMLWriter.OpenItalic: THTMLWriter;
begin
  Result := OpenFormatTag(ftItalic);
end;

function THTMLWriter.OpenKeyboard: THTMLWriter;
begin
  Result := OpenFormatTag(ftKeyboard);
end;

function THTMLWriter.OpenLabel: THTMLWriter;
begin
  CheckInFormTag;
  Result := AddTag(cLabel);
end;

function THTMLWriter.OpenLabel(aFor: string): THTMLWriter;
begin
  Result := OpenLabel[cFor, aFor];
end;

function THTMLWriter.OpenLegend: THTMLWriter;
begin
  CheckInFieldSetTag;
  Result := AddTag(cLegend);
end;

function THTMLWriter.OpenLink: THTMLWriter;
begin
  Result := AddTag(cLink, ctEmpty);
end;

function THTMLWriter.OpenListItem: THTMLWriter;
begin
  CheckInListTag;
  Result := AddTag(cListItem);
end;

function THTMLWriter.OpenMap: THTMLWriter;
begin
  Result := AddTag(cMap);
  Include(Result.FTagState, tsInMapTag);
end;

function THTMLWriter.OpenMeta: THTMLWriter;
begin
  CheckInHeadTag;
  Result := AddTag(cMeta, ctEmpty);
end;

function THTMLWriter.OpenNoFrames: THTMLWriter;
begin
  Result := AddTag(cNoFrames);
end;

function THTMLWriter.OpenNoScript: THTMLWriter;
begin
  Result := AddTag(cNoScript);
end;

function THTMLWriter.OpenStrike: THTMLWriter;
begin
  Result := OpenFormatTag(ftStrike);
end;

function THTMLWriter.OpenStrong: THTMLWriter;
begin
  Result := OpenFormatTag(ftStrong);
end;

function THTMLWriter.OpenTable: THTMLWriter;
begin
  Result := OpenTable(-1, -1, -1);
end;

function THTMLWriter.OpenTable(aBorder: integer): THTMLWriter;
begin
  Result := OpenTable(aBorder, -1, -1);
end;

function THTMLWriter.OpenTable(aBorder: integer; aCellPadding: integer): THTMLWriter;
begin
  Result := OpenTable(aBorder, aCellPadding, -1);
end;

function THTMLWriter.OpenTable(aBorder, aCellPadding, aCellSpacing: integer): THTMLWriter;
begin
  Result := OpenTable(aBorder, aCellPadding, aCellSpacing, THTMLWidth.Create(-1, False));
end;

function THTMLWriter.OpenTable(aBorder: integer; aCellPadding: integer; aCellSpacing: integer; aWidth: THTMLWidth): THTMLWriter;
begin
  Result := AddTag(cTable);
  if aBorder >= 0 then
  begin
    Result := Result.AddAttribute(cBorder, IntToStr(aBorder));
  end;
  if aCellPadding >= 0 then
  begin
    Result := Result.AddAttribute(cCellPadding, IntToStr(aCellPadding));
  end;
  if aCellSpacing >= 0 then
  begin
    Result := Result.AddAttribute(cCellSpacing, IntToStr(aCellSpacing));
  end;
  if aWidth.Width >= 0 then
  begin
    if aWidth.IsPercentage then
    begin
      Result := Result.AddAttribute(cWidth, aWidth.AsPercentage);
    end
    else
    begin
      Result := Result.AddAttribute(aWidth.WidthString);
    end;
  end;

  Result.FTagState := Result.FTagState + [tsInTableTag, tsTableIsOpen];
  Result.FTableState := Result.FTableState + [tbsInTable];
end;

function THTMLWriter.OpenTableData: THTMLWriter;
begin
  CheckInTableRowTag;
  Result := AddTag(cTableData);
end;

function THTMLWriter.OpenTableRow: THTMLWriter;
begin
  CheckInTableTag;
  Result := AddTag(cTableRow);
  Result.FTagState := Result.FTagState + [tsInTableRowTag];
end;

function THTMLWriter.OpenTeletype: THTMLWriter;
begin
  Result := OpenFormatTag(ftTeletype);
end;

function THTMLWriter.OpenTitle: THTMLWriter;
begin
  CheckInHeadTag;
  Result := AddTag(cTitle);
end;

function THTMLWriter.OpenUnderline: THTMLWriter;
begin
  Result := OpenFormatTag(ftUnderline);
end;

function THTMLWriter.OpenUnorderedList(aBulletShape: TBulletShape = bsNone): THTMLWriter;
begin
  Result := AddTag(cUnorderedList);
  if aBulletShape <> bsNone then
  begin
    Result := Result.AddAttribute(cType, TBulletShapeStrings[aBulletShape]);
  end;
  Result.FTagState := Result.FTagState + [tsInListTag];
end;

function THTMLWriter.OpenVariable: THTMLWriter;
begin
  Result := OpenFormatTag(ftVariable);
end;

procedure THTMLWriter.SaveToFile(const FileName: string);
begin
  SaveToFile(FileName, nil);
end;

procedure THTMLWriter.SaveToFile(const FileName: string; Encoding: TEncoding);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream, Encoding);
  finally
    Stream.Free;
  end;
end;

procedure THTMLWriter.LoadFromFile(const FileName: string; Encoding: TEncoding);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(Stream, Encoding);
  finally
    Stream.Free;
  end;
end;

procedure THTMLWriter.LoadFromFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure THTMLWriter.LoadFromStream(Stream: TStream);
begin
  LoadFromStream(Stream, nil);
end;

procedure THTMLWriter.LoadFromStream(Stream: TStream; Encoding: TEncoding);
var
  SS: TStringStream;
begin
  if Encoding = nil then
  begin
    Encoding := TEncoding.Default;
  end;
  SS := TStringStream.Create('', Encoding);
  try
    SS.LoadFromStream(Stream);
    FHTML.Clear;
    FHTML := FHTML.Append(SS.DataString);
  finally
    SS.Free;
  end;
end;

procedure THTMLWriter.SaveToStream(Stream: TStream; Encoding: TEncoding);
var
  SS: TStringStream;
begin
  if Encoding = nil then
  begin
    Encoding := TEncoding.Default;
  end;
  SS := TStringStream.Create(FHTML.ToString, Encoding);
  try
    Stream.CopyFrom(SS, SS.Size);
  finally
    SS.Free;
  end;
end;

procedure THTMLWriter.PushClosingTagOnStack(aCloseTagType: TCloseTagType; aString: string = '');
begin
  case aCloseTagType of
    ctNormal:
      FClosingTags.Push(TTagMaker.MakeCloseTag(aString));
    ctEmpty:
      FClosingTags.Push(TTagMaker.MakeSlashCloseTag);
    ctComment:
      FClosingTags.Push(TTagMaker.MakeCommentCloseTag);
  end;
end;

procedure THTMLWriter.SaveToStream(Stream: TStream);
begin
  SaveToStream(Stream, nil);
end;

function THTMLWriter.OpenObject: THTMLWriter;
begin
  Result := AddTag(cObject);
  Include(Result.FTagState, tsInObjectTag);
end;

function THTMLWriter.OpenOrderedList(aNumberType: TNumberType): THTMLWriter;
begin
  Result := AddTag(cOrderedList);
  if aNumberType <> ntNone then
  begin
    Result := Result.AddAttribute(cType, TNumberTypeStrings[aNumberType]);
  end;
  Result.FTagState := Result.FTagState + [tsInListTag];
end;

procedure THTMLWriter.CleanUpTagState;
begin
  FTagState := FTagState + [tsTagClosed] - [tsTagOpen];

  if TableIsOpen then
  begin
    Exclude(FTagState, tsTableIsOpen);
    FTableState := [];
  end;

  if (FCurrentTagName = cObject) and InObjectTag then
  begin
    Exclude(FTagState, tsInObjectTag);
  end;

  if (FCurrentTagName = cMap) and InMapTag then
  begin
    Exclude(FTagState, tsInMapTag);
  end;

  if (FCurrentTagName = cFrameSet) and InFrameSetTag then
  begin
    Exclude(FTagState, tsInFramesetTag);
  end;

  if (FCurrentTagName = cFieldSet) and InFieldSetTag then
  begin
    Exclude(FTagState, tsInFieldSetTag);
  end;

  if (FCurrentTagName = cComment) and InCommentTag then
  begin
    Exclude(FTagState, tsCommentOpen);
  end;

  if (FCurrentTagName = cForm) and InFormTag then
  begin
    Exclude(FTagState, tsInFormTag);
  end;

  if (FCurrentTagName = cUnorderedList) and InListTag then
  begin
    Exclude(FTagState, tsInListTag);
  end;

  if (FCurrentTagName = cOrderedList) and InListTag then
  begin
    Exclude(FTagState, tsInListTag);
  end;

  if (FCurrentTagName = cTable) and InTableTag then
  begin
    Exclude(FTagState, tsInTableTag);
  end;

  if (FCurrentTagName = cHead) and InHeadTag then
  begin
    Exclude(FTagState, tsInHeadTag);
  end;

  if (FCurrentTagName = cBody) and InBodyTag then
  begin
    Exclude(FTagState, tsInBodyTag);
  end;

  if (FCurrentTagName = cTableRow) and InTableRowTag then
  begin
    Exclude(FTagState, tsInTableRowTag);
  end;

  FCurrentTagName := '';
end;

function THTMLWriter.AddTableData(aText: string): THTMLWriter;
begin
  CheckInTableRowTag;
  Result := OpenTableData.AddText(aText).CloseTag;
end;

function THTMLWriter.AddTag(aString: string; aCloseTagType: TCloseTagType = ctNormal; aCanAddAttributes: TCanHaveAttributes = chaCanHaveAttributes): THTMLWriter;
begin
  CloseBracket;
  Result := THTMLWriter.Create(aString, aCloseTagType, aCanAddAttributes);
  Result.FHTML := Self.FHTML.Append(Result.FHTML.ToString);
  Result.FTagState := Self.FTagState + [tsBracketOpen];
  Result.FParent := Self;
end;

function THTMLWriter.OpenCode: THTMLWriter;
begin
  Result := OpenFormatTag(ftCode);
end;

function THTMLWriter.OpenComment: THTMLWriter;
begin
  CloseBracket;
  Result := THTMLWriter.Create(cComment, ctComment, chaCannotHaveAttributes);
  Result.FHTML := Self.FHTML.Append(Result.FHTML.ToString).Append(cSpace);
  Result.FTagState := Result.FTagState + [tsCommentOpen];
  Result.FParent := Self;
end;

function THTMLWriter.AsHTML: string;
begin
  Result := FHTML.ToString;
end;

function THTMLWriter.AddTeletypeText(aString: string): THTMLWriter;
begin
  Result := AddFormattedText(aString, ftTeletype);
end;

function THTMLWriter.AddText(aString: string): THTMLWriter;
begin
  CloseBracket;
  FHTML := FHTML.Append(aString);
  Result := Self;
end;

function THTMLWriter.AddTitle(aTitleText: string): THTMLWriter;
begin
  CheckInHeadTag;
  Result := OpenTitle.AddText(aTitleText).CloseTag;
end;

function THTMLWriter.AddHardRule(const aAttributes: string = ''; aUseEmptyTag: TIsEmptyTag = ietIsEmptyTag): THTMLWriter;
begin
  CloseBracket;
  FHTML := FHTML.Append(cOpenBracket).Append(cHardRule);
  if not StringIsEmpty(aAttributes) then
  begin
    FHTML := FHTML.Append(cSpace).Append(aAttributes);
  end;
  case aUseEmptyTag of
    ietIsEmptyTag:
      begin
        FHTML := FHTML.Append(TTagMaker.MakeSlashCloseTag);
      end;
    ietIsNotEmptyTag:
      begin
        FHTML := FHTML.Append(cCloseBracket);
      end;
  end;
  Result := Self;
end;

function THTMLWriter.OpenHead: THTMLWriter;
begin
  Result := AddTag(cHead, ctNormal, chaCanHaveAttributes);
  Result.FTagState := Result.FTagState + [tsInHeadTag];
end;

function THTMLWriter.AddHeading1Text(aString: string): THTMLWriter;
begin
  Result := AddHeadingText(aString, htHeading1);
end;

function THTMLWriter.AddHeading2Text(aString: string): THTMLWriter;
begin
  Result := AddHeadingText(aString, htHeading2);
end;

function THTMLWriter.AddHeading3Text(aString: string): THTMLWriter;
begin
  Result := AddHeadingText(aString, htHeading3);
end;

function THTMLWriter.AddHeading4Text(aString: string): THTMLWriter;
begin
  Result := AddHeadingText(aString, htHeading4);
end;

function THTMLWriter.AddHeading5Text(aString: string): THTMLWriter;
begin
  Result := AddHeadingText(aString, htHeading5);
end;

function THTMLWriter.AddHeading6Text(aString: string): THTMLWriter;
begin
  Result := AddHeadingText(aString, htHeading6);
end;

function THTMLWriter.OpenAnchor: THTMLWriter;
begin
  Result := AddTag(cAnchor);
end;

function THTMLWriter.OpenAbbreviation: THTMLWriter;
begin
  Result := OpenFormatTag(ftAbbreviation);
end;

function THTMLWriter.OpenAcronym: THTMLWriter;
begin
  Result := OpenFormatTag(ftAcronym);
end;

function THTMLWriter.OpenAddress: THTMLWriter;
begin
  Result := OpenFormatTag(ftAddress);
end;

function THTMLWriter.OpenAnchor(const aHREF: string; aText: string): THTMLWriter;
begin
  Result := OpenAnchor.AddAttribute(cHREF, aHREF).AddText(aText);
end;

function THTMLWriter.OpenAnchor(aName: string): THTMLWriter;
begin
  Result := OpenAnchor[cName, aName];
end;

function THTMLWriter.OpenArea: THTMLWriter;
begin
  CheckInMapTag;
  Result := AddTag(cArea, ctEmpty);
end;

procedure THTMLWriter.CloseTheTag;
var
  TagToAppend: string;
begin
  if TagIsOpen or InCommentTag then
  begin
    if FClosingTags.Count = 0 then
    begin
      raise EEmptyStackHTMLWriterExeption.Create(strStackIsEmpty);
    end;
    TagToAppend := FClosingTags.Pop;
    FHTML.Append(TagToAppend);
  end;
end;

function THTMLWriter.OpenBase: THTMLWriter;
begin
  CheckInHeadTag;
  Result := AddTag(cBase, ctEmpty);
end;

function THTMLWriter.OpenBaseFont: THTMLWriter;
begin
  CheckInHeadTag;
  Result := AddTag(cBaseFont, ctEmpty);
end;

function THTMLWriter.OpenBDO: THTMLWriter;
begin
  Result := OpenFormatTag(ftBDO);
end;

function THTMLWriter.OpenBig: THTMLWriter;
begin
  Result := OpenFormatTag(ftBig);
end;

function THTMLWriter.OpenBlockQuote: THTMLWriter;
begin
  Result := AddTag(cBlockQuote, ctNormal, chaCanHaveAttributes);
end;

function THTMLWriter.OpenBody: THTMLWriter;
begin
  Result := AddTag(cBody, ctNormal, chaCanHaveAttributes);
end;

function THTMLWriter.AddBase(aHREF: string): THTMLWriter;
begin
  CheckInHeadTag;
  Result := OpenBase.AddAttribute(cHREF, aHREF).CloseTag;
end;

function THTMLWriter.AddBase(aTarget: TTargetType; aFrameName: string = ''): THTMLWriter;
begin
  if aTarget = ttFrameName then
  begin
    Result := OpenBase.AddAttribute(cTarget, aFrameName).CloseTag;
  end
  else
  begin
    Result := OpenBase.AddAttribute(cTarget, TTargetTypeStrings[aTarget]).CloseTag;
  end;
end;

function THTMLWriter.AddBDOText(aString: string): THTMLWriter;
begin
  Result := AddFormattedText(aString, ftBDO);
end;

function THTMLWriter.AddBigText(aString: string): THTMLWriter;
begin
  Result := AddFormattedText(aString, ftBig);
end;

function THTMLWriter.AddBlockQuoteText(aString: string): THTMLWriter;
begin
  Result := AddTag(cBlockQuote, ctNormal, chaCannotHaveAttributes).AddText(aString).CloseTag;
end;

function THTMLWriter.AddBoldText(aString: string): THTMLWriter;
begin
  Result := AddFormattedText(aString, ftBold)
end;

function THTMLWriter.AddCaption(aCaption: string): THTMLWriter;
begin
  if not TableIsOpen then
  begin
    raise ETableTagNotOpenHTMLWriterException.Create(strCantOpenCaptionOutsideTable);
  end;
  Result := AddTag(cCaption).AddText(aCaption).CloseTag;
end;

function THTMLWriter.AddCenterText(aString: string): THTMLWriter;
begin
  Result := AddFormattedText(aString, ftCenter);
end;

function THTMLWriter.AddCitationText(aString: string): THTMLWriter;
begin
  Result := AddFormattedText(aString, ftCitation);
end;

function THTMLWriter.AddClass(aClass: string): THTMLWriter;
begin
  Result := AddAttribute(cClass, aClass);
end;

function THTMLWriter.AddCodeText(aString: string): THTMLWriter;
begin
  Result := AddFormattedText(aString, ftCode);
end;

function THTMLWriter.AddComment(aCommentText: string): THTMLWriter;
begin
  Result := OpenComment.AddText(aCommentText).CloseComment;
end;

function THTMLWriter.AddDefinitionText(aString: string): THTMLWriter;
begin
  Result := AddFormattedText(aString, ftDefinition);
end;

function THTMLWriter.AddDeleteText(aString: string): THTMLWriter;
begin
  Result := AddFormattedText(aString, ftDelete);
end;

function THTMLWriter.AddDivText(aString: string): THTMLWriter;
begin
  Result := AddTag(TBlockTypeStrings[btDiv], ctNormal, chaCannotHaveAttributes).AddText(aString).CloseTag;
end;

function THTMLWriter.AddDivTextWithID(aString, aID: string): THTMLWriter;
begin
  Result := OpenDiv.AddID(aID).AddText(aString).CloseTag;
end;

function THTMLWriter.AddDivTextWithStyle(aString, aStyle: string): THTMLWriter;
begin
  Result := OpenDiv.AddStyle(aStyle).AddText(aString).CloseTag;
end;

function THTMLWriter.AddEmphasisText(aString: string): THTMLWriter;
begin
  Result := AddFormattedText(aString, ftEmphasis)
end;

function THTMLWriter.AddSampleText(aString: string): THTMLWriter;
begin
  Result := AddFormattedText(aString, ftSample);
end;

function THTMLWriter.AddScript(aScriptText: string): THTMLWriter;
begin
  Result := OpenScript.AddText(aScriptText).CloseTag;
end;

function THTMLWriter.AddSmallText(aString: string): THTMLWriter;
begin
  Result := AddFormattedText(aString, ftSmall);
end;

function THTMLWriter.AddSpanText(aString: string): THTMLWriter;
begin
  Result := AddTag(TBlockTypeStrings[btSpan], ctNormal, chaCannotHaveAttributes).AddText(aString).CloseTag;
end;

function THTMLWriter.AddSpanTextWithID(aString, aID: string): THTMLWriter;
begin
  Result := OpenSpan.AddID(aID).AddText(aString).CloseTag;
end;

function THTMLWriter.AddSpanTextWithStyle(aString, aStyle: string): THTMLWriter;
begin
  Result := OpenSpan.AddStyle(aStyle).AddText(aString).CloseTag;
end;

function THTMLWriter.AddStrikeText(aString: string): THTMLWriter;
begin
  Result := AddFormattedText(aString, ftStrike);
end;

function THTMLWriter.AddStrongText(aString: string): THTMLWriter;
begin
  Result := AddFormattedText(aString, ftStrong)
end;

function THTMLWriter.AddUnderlinedText(aString: string): THTMLWriter;
begin
  Result := AddFormattedText(aString, ftUnderline)
end;

function THTMLWriter.AddVariableText(aString: string): THTMLWriter;
begin
  Result := AddFormattedText(aString, ftVariable)
end;

function THTMLWriter.AddID(aID: string): THTMLWriter;
begin
  Result := AddAttribute(cID, aID);
end;

function THTMLWriter.AddIFrame(aURL, aAlternateText: string): THTMLWriter;
begin
  Result := OpenIFrame(aURL).AddText(aAlternateText).CloseTag;
end;

function THTMLWriter.AddIFrame(aURL, aAlternateText: string; aWidth: THTMLWidth; aHeight: integer): THTMLWriter;
begin
  Result := OpenIFrame(aURL, aWidth, aHeight).AddText(aAlternateText).CloseTag;
end;

function THTMLWriter.AddItalicText(aString: string): THTMLWriter;
begin
  Result := AddFormattedText(aString, ftItalic)
end;

function THTMLWriter.AddKeyboardText(aString: string): THTMLWriter;
begin
  Result := AddFormattedText(aString, ftKeyboard)
end;

function THTMLWriter.AddLegend(aText: string): THTMLWriter;
begin
  Result := OpenLegend.AddText(aText).CloseTag;
end;

function THTMLWriter.AddLineBreak(const aClearValue: TClearValue = cvNoValue; aUseEmptyTag: TIsEmptyTag = ietIsEmptyTag): THTMLWriter;
begin
  CloseBracket;
  FHTML := FHTML.Append(cOpenBracket).Append(cBreak);
  if aClearValue <> cvNoValue then
  begin
    FHTML := FHTML.Append(cSpace).AppendFormat('%s="%s"', [cClear, TClearValueStrings[aClearValue]]);
  end;
  case aUseEmptyTag of
    ietIsEmptyTag:
      begin
        FHTML := FHTML.Append(TTagMaker.MakeSlashCloseTag);
      end;
    ietIsNotEmptyTag:
      begin
        FHTML := FHTML.Append(cCloseBracket);
      end;
  end;

  Result := Self;
end;

function THTMLWriter.AddListItem(aText: string): THTMLWriter;
begin
  Result := OpenListItem.AddText(aText).CloseTag;
end;

procedure THTMLWriter.CheckBracketOpen(aString: string);
begin
  if not(tsBracketOpen in FTagState) then
  begin
    raise EHTMLWriterOpenTagRequiredException.CreateFmt(StrATagsBracketMust, [Self.FCurrentTagName, aString]);
  end;
end;

procedure THTMLWriter.CheckInTableTag;
begin
  if not InTableTag then
  begin
    raise ENotInTableTagException.Create(strMustBeInTable);
  end;
end;

procedure THTMLWriter.CheckInTableRowTag;
begin
  if not InTableRowTag then
  begin
    raise ENotInTableTagException.Create(strMustBeInTableRow);
  end;
end;

procedure THTMLWriter.CheckInListTag;
begin
  if not InListTag then
  begin
    raise ENotInListTagException.Create(strMustBeInList);
  end;
end;

procedure THTMLWriter.CheckInMapTag;
begin
  if not InMapTag then
  begin
    raise ENotInMapTagHTMLException.Create(strNotInMapTag);
  end;
end;

procedure THTMLWriter.CheckInObjectTag;
begin
  if not InObjectTag then
  begin
    raise ENotInObjectTagException.Create(strMustBeInObject);
  end;

end;

procedure THTMLWriter.CheckInCommentTag;
begin
  if not InCommentTag then
  begin
    raise ENotInCommentTagException.Create(strMustBeInComment);
  end;
end;

procedure THTMLWriter.CheckInFieldSetTag;
begin
  if not InFieldSetTag then
  begin
    raise ENotInFieldsetTagException.Create(strNotInFieldTag);
  end;
end;

procedure THTMLWriter.CheckCurrentTagIsHTMLTag;
begin
  if FCurrentTagName <> cHTML then
  begin
    raise EClosingDocumentWithOpenTagsHTMLException.Create(strOtherTagsOpen);
  end;
end;

procedure THTMLWriter.CheckInFormTag;
begin
  if not InFormTag then
  begin
    raise ENotInFormTagHTMLException.Create(strNotInFormTag);
  end;
end;

procedure THTMLWriter.CheckInFramesetTag;
begin
  if not InFrameSetTag then
  begin
    raise ENotInFrameSetHTMLException.Create(strNotInFrameSet);
  end;
end;

procedure THTMLWriter.CheckInHeadTag;
begin
  if not InHeadTag then
  begin
    raise EHeadTagRequiredHTMLException.Create(strAMetaTagCanOnly);
  end;
end;

function THTMLWriter.AddMetaNamedContent(aName, aContent: string): THTMLWriter;
begin
  CheckInHeadTag;
  Result := AddAttribute(cName, aName).AddAttribute(cContent, aContent);
end;

function THTMLWriter.AddParagraphText(aString: string): THTMLWriter;
begin
  Result := AddTag(TBlockTypeStrings[btParagraph], ctNormal, chaCannotHaveAttributes).AddText(aString).CloseTag;
end;

function THTMLWriter.AddParagraphTextWithID(aString, aID: string): THTMLWriter;
begin
  Result := OpenParagraph.AddID(aID).AddText(aString).CloseTag;
end;

function THTMLWriter.AddParagraphTextWithStyle(aString, aStyle: string): THTMLWriter;
begin
  Result := OpenParagraph.AddStyle(aStyle).AddText(aString).CloseTag;
end;

function THTMLWriter.AddPreformattedText(aString: string): THTMLWriter;
begin
  Result := AddFormattedText(aString, ftPreformatted)
end;

function THTMLWriter.AddQuotationText(aString: string): THTMLWriter;
begin
  Result := AddFormattedText(aString, ftQuotation)
end;

function THTMLWriter.AddRawText(aString: string): THTMLWriter;
begin
  FHTML := FHTML.Append(aString);
  Result := Self;
end;

function THTMLWriter.OpenParagraphWithID(aID: string): THTMLWriter;
begin
  Result := OpenParagraph.AddID(aID);
end;

function THTMLWriter.OpenParagraph: THTMLWriter;
begin
  Result := AddTag(TBlockTypeStrings[btParagraph], ctNormal, chaCanHaveAttributes);
end;

function THTMLWriter.OpenParagraphWithStyle(aStyle: string): THTMLWriter;
begin
  Result := OpenParagraph.AddStyle(aStyle);
end;

function THTMLWriter.OpenParam(aName: string; aValue: string = ''): THTMLWriter;
begin
  CheckInObjectTag;
  if StringIsEmpty(aName) then
  begin
    raise EParamNameRequiredHTMLWriterException.Create(strParamNameRequired);
  end;
  Result := AddTag(cParam)[cName, aName];
  if StringIsNotEmpty(aValue) then
  begin
    Result := Result[cValue, aValue];
  end;
end;

function THTMLWriter.OpenPre: THTMLWriter;
begin
  Result := OpenFormatTag(ftPreformatted);
end;

function THTMLWriter.OpenQuotation: THTMLWriter;
begin
  Result := OpenFormatTag(ftQuotation);
end;

function THTMLWriter.OpenSample: THTMLWriter;
begin
  Result := OpenFormatTag(ftSample);
end;

function THTMLWriter.OpenScript: THTMLWriter;
begin
  Result := AddTag(cScript);
end;

function THTMLWriter.OpenSmall: THTMLWriter;
begin
  Result := OpenFormatTag(ftSmall);
end;

function THTMLWriter.OpenSpan: THTMLWriter;
begin
  Result := AddTag(TBlockTypeStrings[btSpan], ctNormal, chaCanHaveAttributes);
end;

function THTMLWriter.AddStyle(aStyle: string): THTMLWriter;
begin
  Result := AddAttribute(cStyle, aStyle);
end;

function THTMLWriter.OpenDefinition: THTMLWriter;
begin
  Result := OpenFormatTag(ftDefinition);
end;

function THTMLWriter.OpenDelete: THTMLWriter;
begin
  Result := OpenFormatTag(ftDelete);
end;

function THTMLWriter.OpenDiv: THTMLWriter;
begin
  Result := AddTag(TBlockTypeStrings[btDiv], ctNormal, chaCanHaveAttributes);
end;

function THTMLWriter.AddFontText(aString: string): THTMLWriter;
begin
  Result := AddFormattedText(aString, ftFont);
end;

function THTMLWriter.AddFormattedText(aString: string; aFormatType: TFormatType): THTMLWriter;
begin
  Result := AddTag(TFormatTypeStrings[aFormatType], ctNormal, chaCannotHaveAttributes).AddText(aString).CloseTag;
end;

function THTMLWriter.AddHeadingText(aString: string; aHeadingType: THeadingType): THTMLWriter;
begin
  Result := AddTag(THeadingTypeStrings[aHeadingType], ctNormal, chaCannotHaveAttributes).AddText(aString).CloseTag;
end;

function THTMLWriter.AddAbbreviationText(aString: string): THTMLWriter;
begin
  Result := AddFormattedText(aString, ftAbbreviation);
end;

function THTMLWriter.AddAcronymText(aString: string): THTMLWriter;
begin
  Result := AddFormattedText(aString, ftAcronym);
end;

function THTMLWriter.AddAddressText(aString: string): THTMLWriter;
begin
  Result := AddFormattedText(aString, ftAddress);
end;

function THTMLWriter.AddAnchor(const aHREF: string; aText: string): THTMLWriter;
begin
  Result := OpenAnchor[cHREF, aHREF].AddText(aText).CloseTag;
end;

function THTMLWriter.AddAttribute(aString: string; aValue: string = ''): THTMLWriter;
begin
  CheckBracketOpen(aString);
  FHTML := FHTML.Append(cSpace).Append(aString);
  if aValue <> '' then
  begin
    FHTML := FHTML.Append(Format('="%s"', [aValue]));
  end;
  Result := Self;
end;

end.

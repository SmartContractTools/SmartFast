# -*- coding:utf-8 -*-

import os
import time
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Image, PageBreak, Table, TableStyle
from reportlab.platypus.flowables import Macro
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import A4
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.graphics.charts.piecharts import Pie
from reportlab.graphics.shapes import Drawing, Rect
from reportlab.graphics.charts.textlabels import Label
from reportlab.graphics.charts.legends import Legend
from collections import OrderedDict

class NumberedCanvasChinese(canvas.Canvas):
    def __init__(self, *args, **kwargs):
        canvas.Canvas.__init__(self, *args, **kwargs)
        self._codes = []
    def showPage(self):
        self._codes.append({'code': self._code, 'stack': self._codeStack})
        self._startPage()
    def save(self):
        """add page info to each page (page x of y)"""
        # reset page counter 
        self._pageNumber = 0
        global time_start, auditid
        time_ym = time.strftime('%Y{y}%m{m}', time_start).format(y='年', m='月')
        for code in self._codes:
            # recall saved page
            self._code = code['code']
            self._codeStack = code['stack']
            if self._pageNumber == 0:
                self.drawImage('/home/smartcontract/SmartContract/smartfast-master-01/smartfast/report/report-positive.jpg',0,0,A4[0],A4[1])
                self.setFillColorRGB(1,1,1) #choose your font colour
                self.setFont("hei", 20) #choose your font type and font size
                self.drawString(177, 396, '编号：'+ auditid)
                self.drawString(177, 346, '日期：'+ time.strftime("%Y-%m-%d", time_start))
            elif self._pageNumber == len(self._codes)-1:
                self.drawImage('/home/smartcontract/SmartContract/smartfast-master-01/smartfast/report/report-back.jpg',0,0,A4[0],A4[1])
            else:
                self.setFillColorRGB(0.15,0.42,0.65)#37,107,166
                self.setStrokeColorRGB(0.15,0.42,0.65)
                self.rect(65, 775, 20, 50, stroke=1, fill=1)
                self.setFont("songti", 12) #choose your font type and font size
                self.drawString(90, 802, '智能合约安全审计报告')
                self.drawString(90, 780, time_ym)
                self.drawImage('/home/smartcontract/SmartContract/smartfast-master-01/smartfast/report/logo.jpg', 275, 780, width=100,height=40)
                self.drawImage('/home/smartcontract/SmartContract/smartfast-master-01/smartfast/report/yemei.jpg', 385, 785, width=140,height=30)
                self.line(180,775,530,775)
                self.setFont("hei", 10.5)
                self.drawCentredString(295, 30,
                    "%(this)i / %(end)i" % {
                       'this': self._pageNumber,
                       'end': len(self._codes)-2,
                    }
                )
            canvas.Canvas.showPage(self)
        canvas.Canvas.save(self)


class ReportChinese():
	pdfmetrics.registerFont(TTFont('hei', "MSYH.TTC"))
	pdfmetrics.registerFont(TTFont('songti', "simsun.ttc"))
	pdfmetrics.registerFont(TTFont('heiti', "simhei.ttf"))
	pdfmetrics.registerFont(TTFont('roman', "times.ttf"))

	time_start = None
	auditid = None

	title_style = ParagraphStyle(name="TitleStyle", fontName="heiti", fontSize=14, alignment=TA_LEFT,leading=20,spaceAfter=10,spaceBefore=10,textColor=colors.HexColor(0x256BA6),)
	sub_title_style = ParagraphStyle(name="SubTitleStyle", fontName="heiti", fontSize=12,
	                                      textColor=colors.HexColor(0x256BA6), alignment=TA_LEFT, spaceAfter=7,spaceBefore=2,)
	sub_sub_title_style = ParagraphStyle(name="SubTitleStyle", fontName="heiti", fontSize=12,
	                                      textColor=colors.black, alignment=TA_LEFT, spaceAfter=8,spaceBefore=5,)
	sub_title_style_romanbold = ParagraphStyle(name="SubTitleStyleRomanbold", fontName="heiti", fontSize=12,
	                                      textColor=colors.HexColor(0x256BA6), alignment=TA_LEFT, spaceAfter=7,spaceBefore=2,)
	content_daoyin_style = ParagraphStyle(name="ContentDaoyinStyle", fontName="hei", fontSize=12, leading=20,
	                                    wordWrap = 'CJK', firstLineIndent = 24)
	content_daoyin_style_red = ParagraphStyle(name="ContentDaoyinStyleRed", fontName="hei", fontSize=12, leading=20,
	                                    wordWrap = 'CJK', textColor=colors.red)
	content_style = ParagraphStyle(name="ContentStyle", fontName="songti", fontSize=12, leading=20,
	                                    wordWrap = 'CJK', firstLineIndent = 24)
	content_style_noindent = ParagraphStyle(name="ContentStyleNoindent", fontName="songti", fontSize=12, leading=20,
	                                    wordWrap = 'CJK')
	content_style_roman = ParagraphStyle(name="ContentStyleRoman", fontName="roman", fontSize=12, leading=20,
	                                    wordWrap = 'CJK', firstLineIndent = 24)
	content_style_codeadd = ParagraphStyle(name="ContentStyle", fontName="songti", fontSize=10.5, leading=20,
	                                    wordWrap = 'CJK', firstLineIndent = 24)
	content_style_red = ParagraphStyle(name="ContentStyleRed", fontName="songti", fontSize=12, leading=20,
	                                    wordWrap = 'CJK', firstLineIndent = 24, textColor=colors.red)
	foot_style = ParagraphStyle(name="FootStyle", fontName="hei", fontSize=10.5, textColor=colors.HexColor(0xB4B4B4),
	                                 leading=25, spaceAfter=20, alignment=TA_CENTER, )
	table_title_style = ParagraphStyle(name="TableTitleStyle", fontName="heiti", fontSize=10.5, leading=20,
	                                        spaceAfter=2, alignment=TA_CENTER, )
	graph_title_style = ParagraphStyle(name="GraphTitleStyle", fontName="heiti", fontSize=10.5, leading=20,
	                                        spaceBefore=7, alignment=TA_CENTER, )
	sub_table_style = ParagraphStyle(name="SubTableTitleStyle", fontName="hei", fontSize=10.5, leading=25,
	                                        spaceAfter=10, alignment=TA_LEFT, )
	code_style = ParagraphStyle(name="CodeStyle", fontName="hei", fontSize=9.5, leading=12,
	                                        spaceBefore=5, spaceAfter=5, alignment=TA_LEFT,borderWidth=0.3,borderColor = colors.HexColor(0x256BA6), wordWrap = 'CJK', )
	basic_style = TableStyle([('FONTNAME', (0, 0), (-1, -1), 'hei'),
	                               ('FONTSIZE', (0, 0), (-1, -1), 12),
	                               ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
	                               ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
	                               ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
	                               # 'SPAN' (列,行)坐标
	                               ('SPAN', (1, 0), (3, 0)),
	                               ('SPAN', (1, 1), (3, 1)),
	                               ('SPAN', (1, 2), (3, 2)),
	                               ('SPAN', (1, 5), (3, 5)),
	                               ('SPAN', (1, 6), (3, 6)),
	                               ('SPAN', (1, 7), (3, 7)),
	                               ('GRID', (0, 0), (-1, -1), 0.5, colors.black),
	                               ])
	common_style = TableStyle([('FONTNAME', (0, 0), (-1, 0), 'hei'),
	                           ('FONTNAME', (1, 1), (-1, -1), 'songti'),
	                           ('FONTNAME', (0, 1), (0, -1), 'heiti'),
	                              ('FONTSIZE', (0, 0), (-1, -1), 12),
	                              ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
	                              ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
	                              ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
	                           ('LINEBEFORE', (0, 0), (0, -1), 0.1, colors.grey),  # 设置表格左边线颜色为灰色，线宽为0.1
	                              ('GRID', (0, 0), (-1, -1), 0.1, colors.grey),
	                           ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),  # 设置表格内文字颜色
	                           ('TEXTCOLOR', (0, 1), (-1, -1), colors.black),
	                           ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#4472c4')),  # 设置第一行背景颜色
	                            ('BACKGROUND', (0, 1), (-1, 1), colors.HexColor('#d9e2f3')),  # 设置第二行背景颜色
	                           ('BACKGROUND', (0, 3), (-1, 3), colors.HexColor('#d9e2f3')),
	                           ('BACKGROUND', (0, 5), (-1, 5), colors.HexColor('#d9e2f3')),
	                           ('BACKGROUND', (0, 7), (-1, 7), colors.HexColor('#d9e2f3')),
	                             ])
	common_style_1 = TableStyle([('FONTNAME', (0, 0), (-1, 0), 'hei'),
	                           ('FONTNAME', (0, 1), (0, -1), 'heiti'),
	                           ('FONTNAME', (1, 1), (-1, -1), 'songti'),
	                              ('FONTSIZE', (0, 0), (-1, -1), 12),
	                              ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
	                              ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
	                              ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
	                           ('LINEBEFORE', (0, 0), (0, -1), 0.1, colors.grey),  # 设置表格左边线颜色为灰色，线宽为0.1
	                              ('GRID', (0, 0), (-1, -1), 0.1, colors.grey),
	                           ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),  # 设置表格内文字颜色
	                           ('TEXTCOLOR', (0, 1), (0, -1), colors.HexColor('#E61A1A')),
	                             ('TEXTCOLOR', (1, 1), (1, -1), colors.HexColor('#FF6600')),
	                             ('TEXTCOLOR', (2, 1), (2, -1), colors.HexColor('#DDB822')),
	                             ('TEXTCOLOR', (3, 1), (3, -1), colors.HexColor('#ff66ff')),
	                             ('TEXTCOLOR', (4, 1), (4, -1), colors.HexColor('#22DDDD')),
	#                              ('TEXTCOLOR', (5, 1), (5, -1), colors.HexColor('#2BD591')),
	                           ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#4472c4')),  # 设置第一行背景颜色
	                            ('BACKGROUND', (0, 1), (-1, 1), colors.HexColor('#d9e2f3')),  # 设置第二行背景颜色
	                             ('SPAN', (0, 0), (-1, 0)),
	                             ])
	common_style_result_all_type = [
	                            ('FONTNAME', (0, 0), (-1, 0), 'hei'),
	                            ('FONTNAME', (0, 1), (0, -1), 'roman'),
	                           ('FONTNAME', (1, 1), (1, -1), 'heiti'),
	                           ('FONTNAME', (2, 1), (4, -1), 'songti'),
	                            ('FONTNAME', (5, 1), (5, -1), 'heiti'),
	                              ('FONTSIZE', (0, 0), (-1, -1), 9),
	                              ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
	                              ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
	                              ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
	                           ('LINEBEFORE', (0, 0), (0, -1), 0.1, colors.grey),  # 设置表格左边线颜色为灰色，线宽为0.1
	                              ('GRID', (0, 0), (-1, -1), 0.1, colors.grey),
	                           ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),  # 设置表格内文字颜色
	                           ('TEXTCOLOR', (0, 1), (2, -1), colors.black),
	                            ('TEXTCOLOR', (4, 1), (4, -1), colors.black),
	                            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#4472c4'))  # 设置第一行背景颜色
	                             ]
	content_colors = {'高危':'#E61A1A','中危':'#FF6600','低危':'#DDB822','提醒':'#ff66ff','优化':'#22DDDD','通过':'#2BD591'}
	table_result = [['序号', '审计项目', '项目描述', '危害', '信心', '状态/数量', '描述', '场景', '场景补充', '建议'], [1, 'abiencoderv2-array', 'ABI编码错误', '高危', 'exactly', '通过', 'solc 0.4.7-0.5.10版本包含一个编译器错误，导致错误使用ABI编码器。', 'contract A {<br/>&#160;&#160;&#160;&#160;uint[2][3] bad_arr = [[1, 2], [3, 4], [5, 6]];<br/>&#160;&#160;&#160;&#160;/* Array of arrays passed to abi.encode is vulnerable */<br/>&#160;&#160;&#160;&#160;function bad() public {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;bytes memory b = abi.encode(bad_arr);<br/>&#160;&#160;&#160;&#160;}<br/>}', '在编译器版本为0.4.7-0.5.10时，由于bad()中使用了abi.encode（bad_arr），故调用bad()会将数组错误地编码为[[1、2]，[2、3]，[3、4]]，并导致意外行为。', '使用编译版本>= 0.5.10。'], [2, 'array-by-reference', 'storage参数使用', '高危', 'exactly', '通过', '检测给storage函数传递存储数组的函数（reference）。', 'contract Memory {<br/>&#160;&#160;&#160;&#160;uint[1] public x; // storage<br/>&#160;&#160;&#160;&#160;function f() public {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;f1(x); // update x<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;f2(x); // do not update x<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function f1(uint[1] storage arr) internal { // by reference<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;arr[0] = 1;<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function f2(uint[1] arr) internal { // by value<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;arr[0] = 2;<br/>&#160;&#160;&#160;&#160;}<br/>}', 'Bob调用f()，按理来说Bob在调用结束时x[0]为2，但它为1。因此，Bob对合同的使用不正确。', '确保在功能参数中正确使用内存和存储，使所有位置明确。'], [3, 'multiple-constructors', '一个合约中有多个构造函数', '高危', 'exactly', '通过', '检测同一合同中的多个构造函数定义（使用新旧方案）。', 'contract A {<br/>&#160;&#160;&#160;&#160;uint x;<br/>&#160;&#160;&#160;&#160;constructor() public {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;x = 0;<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function A() public {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;x = 1;<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function test() public returns(uint) {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;return x;<br/>&#160;&#160;&#160;&#160;}<br/>}', '在Solidity 0.4.22中，将同时编译带有两个构造器方案的合同。 第一个构造函数将优先于第二个构造函数，这可能是意外的。所以应该特别注意在Solidity 0.4.22中。', '仅声明一个构造函数，最好使用新的方案构造函数（...）而不是函数<contractName>（...）。'], [4, 'names-reused', '检查合同名称重用', '高危', 'exactly', '通过', '如果一个代码库有两个名称相似的合约，则编译工件将不包含名称重复的合约之一。', 'contract B{<br/>&#160;&#160;&#160;&#160;constructor() {<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function ceshi1() {}<br/>}<br/>contract B{<br/>&#160;&#160;&#160;&#160;constructor() {<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function ceshi2() {}<br/>}', 'Bob的代码库有两个名为“ ERC20”的合同。当代码库运行时，两个合约中只有一个会在“ build / contracts”中被编译。结果，第二合同不能被分析。', '重命名合约。'], [5, 'public-mappings-nested', 'struct套struct的嵌套结构', '高危', 'exactly', '通过', '在Solidity 0.5之前，带有嵌套结构（struct套struct）的公共映射返回不正确的值。', 'contract TestNestedStructInMapping {<br/>&#160;&#160;&#160;&#160;// The struct that is nested.<br/>&#160;&#160;&#160;&#160;struct structNested {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;uint dummy;<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;// The struct that holds the nested struct.<br/>&#160;&#160;&#160;&#160;struct structMain {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;structNested gamePaymentsSummary;<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;// The map that maps a game ID to a specific game.<br/>&#160;&#160;&#160;&#160;mapping(uint256 => structMain) public s_mapOfNestedStructs;<br/>}', '它确实在0.4.25中起作用。但是，向结构中添加另一个变量仍然不会使0.4.25出错，但是生成的代码是错误的-它仅返回32个字节而不是64个字节。Bob与具有嵌套结构的公共映射的合同进行交互。映射返回的值不正确（64字节返回了32字节），破坏了Bob的使用。', '不要将公共映射与嵌套结构（struct套struct）一起使用。'], [6, 'rtlo', '检查从右向左覆盖控制字符', '高危', 'exactly', '通过', '恶意行为者可以使用从右向左覆盖的Unicode字符（U+202E）来强制RTL文本呈现，并使用户实现混淆合同的真正意图。', 'contract Token<br/>{<br/>&#160;&#160;&#160;&#160;address payable o; // owner<br/>&#160;&#160;&#160;&#160;mapping(address => uint) tokens;<br/>&#160;&#160;&#160;&#160;function withdraw() external returns(uint)<br/>&#160;&#160;&#160;&#160;{<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;uint amount = tokens[msg.sender];<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;address payable d = msg.sender;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;token/*noitanitsed*/ d, o/*\u202d\u202c\u202c<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/*value */, amount);<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function _withdraw(address payable fee_receiver, address payable destination, uint value) internal<br/>&#160;&#160;&#160;&#160;{<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;fee_receiver.transfer(1);<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;destination.transfer(value);<br/>&#160;&#160;&#160;&#160;}<br/>}', '当调用`_withdraw`时，`Token`使用从右到左的覆盖字符（上述小方框包含覆盖字符）。 结果，费用被错误地发送到`msg.sender`，并且令牌余额被发送给所有者。', '不允许使用特殊控制字符。'], [7, 'shadowing-state', '检查状态变量隐藏', '高危', 'exactly', '通过', '牢固性允许在使用继承时对状态变量进行歧义命名。当在合同和功能级别上有多个定义时，状态变量隐藏也可能在单个合同内发生。', 'contract BaseContract{<br/>&#160;&#160;&#160;&#160;address owner;<br/>&#160;&#160;&#160;&#160;modifier isOwner(){<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;require(owner == msg.sender);<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;_;<br/>&#160;&#160;&#160;&#160;}<br/>}<br/>contract DerivedContract is BaseContract{<br/>&#160;&#160;&#160;&#160;address owner;<br/>&#160;&#160;&#160;&#160;constructor(){<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;owner = msg.sender;<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function withdraw() isOwner() external{<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;msg.sender.transfer(this.balance);<br/>&#160;&#160;&#160;&#160;}<br/>}', "`BaseContract`的`owner`不会被指定，并且修饰符`isOwner`不起作用。'''", '避免声明有相同变量，在合约继承时，如果必要的话可以修改名称或者写到构造函数中重新赋值等等。'], [8, 'suicidal', '检查是否任何人都能破坏合同', '高危', 'exactly', '通过', '由于缺少访问控制或访问控制不足，恶意方可以自毁合同。调用selfdestruct/suicide缺乏保护。', 'contract Suicidal{<br/>&#160;&#160;&#160;&#160;function kill() public{<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;selfdestruct(msg.sender);<br/>&#160;&#160;&#160;&#160;}<br/>}', 'Bob调用“kill”函数并破坏了合同。', '保护对所有敏感函数的访问。'], [9, 'uninitialized-state', '检查未初始化的状态变量', '高危', 'exactly', '通过', '未初始化的状态变量可能导致有意或无意的漏洞。', 'contract Uninitialized{<br/>&#160;&#160;&#160;&#160;address destination;<br/>&#160;&#160;&#160;&#160;function transfer() payable public{<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;destination.transfer(msg.value);<br/>&#160;&#160;&#160;&#160;}<br/>}', 'Bob调用“transfer”。 结果，以太被发送到地址“ 0x0”并丢失。', '初始化所有变量。 如果要将变量初始化为零，则将其显式设置为零。'], [10, 'uninitialized-storage', '检查未初始化的存储变量', '高危', 'exactly', '通过', '未初始话本地变量。初始化的存储变量将用作对第一个状态变量的引用，并且可以覆盖关键变量。', 'contract Uninitialized{<br/>&#160;&#160;&#160;&#160;address owner = msg.sender;<br/>&#160;&#160;&#160;&#160;struct St{<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;uint a;<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function func() {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;St st;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;st.a = 0x0;<br/>&#160;&#160;&#160;&#160;}<br/>}', 'Bob 调用`func`。 结果，“owner”被覆盖为“ 0”。', '应该初始化存储变量整体，struct、class等，使用结构体的初始化方法，或者添加memory。'], [11, 'unprotected-upgrade', '破坏合约的逻辑', '高危', 'exactly', '通过', '检测可以破坏的逻辑合约。', 'contract Buggy is Initializable{<br/>&#160;&#160;&#160;&#160;address payable owner;<br/><br/>&#160;&#160;&#160;&#160;function initialize() external initializer{<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;require(owner == address(0));<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;owner = msg.sender;<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function kill() external{<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;require(msg.sender == owner);<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;selfdestruct(owner);<br/>&#160;&#160;&#160;&#160;}<br/>}', 'Buggy是可更新的合约。任何人都可以调用逻辑合约上的initialize并销毁合约。', '添加一个构造函数以确保不能在逻辑协定上调用initialize。'], [12, 'visibility', '检查可见性级别错误', '高危\\提醒', 'exactly', '通过', '合约中的默认函数可见性级别是public，在interfaces-external中，状态变量默认可见性级别是internal。在合约中，回退函数可以是external 或public。在接口中，所有函数都应声明为external函数。明确定义函数可见性以防止混淆。具体来说，0.5.0版本以前：寻找没有显式可见性声明的fallback函数 informational exactly删掉，查找既不是external也不是public的fallback函数，查找具有external或private可见性的构造函数，在接口中查找internal和private的函数；0.5.0版本以后：在接口中查找非external函数。', 'pragma solidity ^0.4.24;<br/>interface D {<br/>&#160;&#160;&#160;&#160;function foo() private;<br/>&#160;&#160;&#160;&#160;function foo1() public;<br/>}<br/>contract C {<br/>&#160;&#160;&#160;&#160;address kk;<br/>&#160;&#160;&#160;&#160;constructor() private {<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function aa() public{<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function() {<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '可见性要根据编译器要求进行修改。'], [13, 'redundant-fallback', '检查冗余的回退函数', '高危\\优化', 'exactly', '通过', '从Solidity 0.4.0开始，不具有回退函数的合约会自动还原付款，从而使付款拒绝回退变得多余。但是在0.4以下，没有fallback函数容易发生重入漏洞，十分危险。', 'pragma solidity 0.3.24;<br/>contract Crowdsale {<br/>}', '恶意用户自写fallback函数可对合约进行攻击。', '多编写回退函数并没有错，仅仅只是加一点编译gas，但是有编写回退函数这种意识还是需要鼓励的。'], [14, 'arbitrary-send', '检查以太币是否可以发送到任意地址', '高危', 'probably', '通过', '对将Ether发送到任意地址的函数的调用未进行审查。', 'contract ArbitrarySend{<br/>&#160;&#160;&#160;&#160;address destination;<br/>&#160;&#160;&#160;&#160;function setDestination(){<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;destination = msg.sender;<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function withdraw() public{<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;destination.transfer(this.balance);<br/>&#160;&#160;&#160;&#160;}<br/>}', 'Bob 调用setDestination和withdraw， 结果他提取了合同的余额。', '确保任意用户都不能提取未经授权的资金。'], [15, 'continue-in-loop', '检查continue造成死循环', '高危', 'probably', '通过', 'continue会导致循环判断条件自增失败，从而导致无限循环。', 'contract C {<br/>&#160;&#160;&#160;&#160;function f(uint a, uint b) public{<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;uint a = 0;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;do {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;continue;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;a++;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;} while(a<10);<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '检查增量变量是否被跳过。'], [16, 'controlled-array-length', '长度被直接分配', '高危', 'probably', '通过', '检测数组长度的直接分配。', 'contract A {<br/>&#160;&#160;&#160;&#160;uint[] testArray; // dynamic size array<br/>&#160;&#160;&#160;&#160;function f(uint usersCount) public {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;// ...<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;testArray.length = usersCount;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;// ...<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function g(uint userIndex, uint val) public {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;// ...<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;testArray[userIndex] = val;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;// ...<br/>&#160;&#160;&#160;&#160;}<br/>}', '合约存储/状态变量由256位整数索引。 用户可以将阵列长度设置为2 ** 256-1，以便为所有存储插槽建立索引。 在上面的示例中，可以调用函数f设置阵列长度，然后调用函数g来控制所需的任何存储插槽。 请注意，此处的存储插槽是通过索引器的哈希索引的。 尽管如此，所有存储仍将可访问，并且可以由攻击者控制。', '不允许直接设置数组长度；而是选择根据需要添加值。否则，请彻底检查合同以确保用户控制的变量不能达到数组长度分配。'], [17, 'controlled-delegatecall', '检查委托地址是否受控', '高危', 'probably', '通过', '将呼叫或呼叫代码委托给用户控制的地址。Delegatecall的地址不一定可信，还是访问控制的问题，没有检查该地址。', 'contract Delegatecall{<br/>&#160;&#160;&#160;&#160;function delegate(address to, bytes data){<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;to.delegatecall(data);<br/>&#160;&#160;&#160;&#160;}<br/>}', 'Bob 呼叫`delegate`并将执行委托给他的恶意合同。 结果，Bob 提取了合同的资金并销毁了合同。', '避免使用`delegatecall`，如使用请仅针对受信任的目的地。'], [18, 'incorrect-constructor', '检查构造函数名称错误', '高危', 'probably', '通过', '构造函数是特殊功能，在合同创建期间只能调用一次。他们通常执行关键的特权操作，例如设置合同所有者。在Solidity 0.4.22版之前，定义构造函数的唯一方法是创建一个与包含它的协定类同名的函数。如果其名称与合同名称不完全匹配，则打算成为构造函数的函数将变为普通的可调用函数。此行为有时会导致安全问题，尤其是当智能合约代码以其他名称重复使用但构造函数的名称未相应更改时。', 'contract Incorrectconstructor {<br/>&#160;&#160;&#160;&#160;address owner;<br/>&#160;&#160;&#160;&#160;function Incorrectconstructo() {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;owner = msg.sender;<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;modifier ifowner()<br/>&#160;&#160;&#160;&#160;{<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;require(msg.sender == owner);<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;_;<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function withdrawmoney() ifowner {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;msg.sender.transfer(address(this).balance);<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '请检查构造函数是否错误。'], [19, 'parity-multisig-bug', '检查多签漏洞', '高危', 'probably', '通过', '多重签名漏洞。黑客可以通过initWallet函数调用initMultiowned函数来获取合同所有者的身份。', 'contract WalletLibrary_bad is WalletEvents {<br/>&#160;&#160;&#160;&#160;function initWallet(address[] _owners, uint _required, uint _daylimit) { <br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;initDaylimit(_daylimit); <br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;initMultiowned(_owners, _required);<br/>&#160;&#160;&#160;&#160;}  // kills the contract sending everything to `_to`.<br/>&#160;&#160;&#160;&#160;function initMultiowned(address[] _owners, uint _required) {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;m_numOwners = _owners.length + 1;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;m_owners[1] = uint(msg.sender);<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;m_ownerIndex[uint(msg.sender)] = 1; <br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;for (uint i = 0; i < _owners.length; ++i)<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;{<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;m_owners[2 + i] = uint(_owners[i]);<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;m_ownerIndex[uint(_owners[i])] = 2 + i;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;m_required = _required;<br/>&#160;&#160;&#160;&#160;}<br/>}', '', 'initWallet、initDaylimit及initMultiowned添加internal限定类型，以禁止外部调用：或如果检测到initMultiowned存在only_uninitMultiowned（m_numOwners），则不会出现错误。通过判断m_numOwners也可以对初始化次数进行审查。'], [20, 'reentrancy-eth', '检查重入漏洞（以太币盗窃）', '高危', 'probably', '通过', '检测到重入错误。这个是有以太币的重入。通过重入可对账户余额进行恶意取款，从而导致损失。不要举报不涉及以太币的再举报（请参阅“ reentrancy-no-eth”）', 'function withdrawBalance(){<br/>&#160;&#160;&#160;&#160;// send userBalance[msg.sender] Ether to msg.sender<br/>&#160;&#160;&#160;&#160;// if mgs.sender is a contract, it will call its fallback function<br/>&#160;&#160;&#160;&#160;if( ! (msg.sender.call.value(userBalance[msg.sender])() ) ){<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;throw;<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;userBalance[msg.sender] = 0;<br/>}', 'Bob使用重入漏洞多次调用`withdrawBalance`，并提取了超过其最初存入合同的款项。', '可采用check-effects-interactions模式。'], [21, 'storage-array', '有符号整数数组问题', '高危', 'probably', '通过', 'solc 0.4.7-0.5.10版本包含一个编译器错误，导致有符号整数数组中的值不正确。', 'contract A {<br/>&#160;&#160;&#160;&#160;int[3] ether_balances; // storage signed integer array<br/>&#160;&#160;&#160;&#160;function bad0() private {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;// ...<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;ether_balances = [-1, -1, -1];<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;// ...<br/>&#160;&#160;&#160;&#160;}<br/>}', 'bad0()使用一个（存储分配的）有符号整数数组状态变量来存储三个帐户的ether结余。-1应该表示未初始化的值，但是Solidity错误使它们成为1，这些值可以被帐户利用。', '使用编译器版本> = 0.5.10。'], [22, 'weak-prng', 'block等参数的取模问题', '高危', 'probably', '通过', '由于block.timestamp，now或blockhash的取模，PRNG较弱。这些可能会受到矿工的某种程度的影响，因此应避免使用。', 'contract Game {<br/>&#160;&#160;&#160;&#160;uint reward_determining_number;<br/>&#160;&#160;&#160;&#160;function guessing() external{<br/>&#160;&#160;&#160;&#160;  reward_determining_number = uint256(block.blockhash(10000)) % 10;<br/>&#160;&#160;&#160;&#160;}<br/>}', 'Eve是一名矿工。Eve调用guessing()并重新排序包含交易的区块。结果，Eve赢得了比赛。', '不要现在使用block.timestamp或blockhash作为随机性的来源。'], [23, 'assert-violation', '检查错误使用断言', '中危', 'exactly', '通过', 'Solidity assert()函数用于声明不变量。正常运行的代码永远不 会到达失败的assert语句。可达到的断言可能意味着以下两种情况之一：1、合同中存在一个错误，使它可以进入无效状态。2、该assert语句使用不正确，例如用于验证输入。;CWE-670：总是不正确的控制流实施。Assert条件可为false，这里定义较宽。最好使用requere。一般用于函数结尾处，验证有没有上溢啥的。', 'contract Assertviolation [<br/>&#160;&#160;&#160;&#160;function bad(uint a, uint b){<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;assert(a>b);<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '要检测输入变量，请使用require函数。'], [24, 'constructor-return', '检查构造函数中使用return', '中危', 'exactly', '通过', 'return语句用于合约的构造函数中。使用return，部署的过程将不同于直观的过程。例如，部署的字节码可能不包括在源代码中实现的函数。', 'pragma solidity 0.4.24;<br/>contract HoneyPot {<br/>&#160;&#160;&#160;&#160;bytes internal constant ID = hex"60203414600857005B60008080803031335AF100";<br/>&#160;&#160;&#160;&#160;constructor () public payable {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;bytes memory contract_identifier = ID;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;assembly { return(add(0x20, contract_identifier), mload(contract_identifier)) }<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function withdraw() public payable {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;require(msg.value >= 1 ether);<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;msg.sender.transfer(address(this).balance);<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '在constructor中不要使用assembly的return。'], [25, 'default-return-value', '检查函数仅返回默认值', '中危', 'exactly', '通过', '如果声明一个函数有返回值，而最后没给它返回值，就会产生一个默认的返回值，而默认返回值和实际执行后的返回值可能存在差异。', 'contract C{<br/>&#160;&#160;&#160;&#160;function bad_return() public returns(bool flag){<br/>&#160;&#160;&#160;&#160; &#160;&#160;&#160;&#160;address aa = msg.sender;<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function bad_return1() public returns(bool){<br/>&#160;&#160;&#160;&#160; &#160;&#160;&#160;&#160;address aa = msg.sender;<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '具有返回值的函数应返回或更改返回值。'], [26, 'enum-conversion', '枚举类型的范围', '中危', 'exactly', '通过', '检测超出范围的枚举转换（solc <0.4.5）。', 'pragma solidity 0.4.2;<br/>contract Test{<br/>&#160;&#160;&#160;&#160;enum E{a}<br/>&#160;&#160;&#160;&#160;function bug(uint a) public returns(E){<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;return E(a);   <br/>&#160;&#160;&#160;&#160;}<br/>}', '攻击者可以通过调用bug(1)触发意外行为。', '使用最新的编译器版本。如果要求solc <0.4.5，请检查枚举转换范围。'], [27, 'erc1155-interface', '检查错误的ERC1155接口', '中危', 'exactly', '通过', '“ ERC1155”功能的返回值不正确。 与这些功能交互的，solidity 版本> 0.4.22的合同将无法执行，因为缺少返回值。', 'contract Token{<br/>&#160;&#160;&#160;&#160;function balanceOf(address _owner, uint256 _id) external view returns (bool);<br/>&#160;&#160;&#160;&#160;//...<br/>}', 'Token.balanceOf不返回预期的uint256。 Bob部署令牌。 Alice 创建了一个与之交互的合约，但假定接口是正确的`ERC1155`。 Alice 的合约无法与 Bob的合约互动。', '为定义的ʻERC1155`函数设置适当的返回值和vtypes。'], [28, 'erc1410-interface', '检查错误的ERC1410接口', '中危', 'exactly', '通过', '“ ERC1410”功能的返回值不正确。 与这些功能交互的，solidity 版本> 0.4.22的合同将无法执行，因为缺少返回值。', 'contract Token{<br/>&#160;&#160;&#160;&#160;function isOperator(address _operator, address _tokenHolder) external view returns (uint256);<br/>&#160;&#160;&#160;&#160;//...<br/>}', 'Token.isOperator不返回预期的布尔值。 Bob部署令牌。 Alice 创建了一个与之交互的合约，但采用了正确的`ERC1410`接口实现。Alice 的合约无法与Bob的合约互动。', '为定义的ʻERC1410`函数设置适当的返回值和vtypes。'], [29, 'erc20-interface', '检查错误的ERC20接口', '中危', 'exactly', '通过', '“ ERC20”功能的返回值不正确。 与这些功能交互的，solidity 版本> 0.4.22的合同将无法执行，因为缺少返回值。', 'contract Token{<br/>&#160;&#160;&#160;&#160;function transfer(address to, uint value) external;<br/>&#160;&#160;&#160;&#160;//...<br/>}', 'Token.transfer不返回预期的布尔值。 Bob部署令牌。 Alice 创建了一个与之交互的合约，但采用了正确的`ERC20`接口实现。Alice 的合约无法与Bob的合约互动。', '为定义的ʻERC20`函数设置适当的返回值和vtypes。'], [30, 'erc223-interface', '检查错误的ERC223接口', '中危', 'exactly', '通过', '“ ERC223”功能的返回值不正确。 与这些功能交互的，solidity 版本> 0.4.22的合同将无法执行，因为缺少返回值。', 'contract Token{<br/>&#160;&#160;&#160;&#160;function name() constant returns (uint _name);<br/>&#160;&#160;&#160;&#160;//...<br/>}', 'Token.name不返回预期的布尔值。 Bob部署令牌。 Alice 创建了一个与之交互的合约，但采用了正确的`ERC223`接口实现。Alice 的合约无法与Bob的合约互动。', '为定义的ʻERC223`函数设置适当的返回值和vtypes。'], [31, 'erc621-interface', '检查错误的ERC621接口', '中危', 'exactly', '通过', '“ ERC621”功能的返回值不正确。 与这些功能交互的，solidity 版本> 0.4.22的合同将无法执行，因为缺少返回值。', 'contract Token{<br/>&#160;&#160;&#160;&#160;function decreaseSupply(uint value, address from) external;<br/>&#160;&#160;&#160;&#160;//...<br/>}', 'Token.decreaseSupply不返回预期的布尔值。 Bob部署令牌。 Alice 创建了一个与之交互的合约，但采用了正确的`ERC621`接口实现。Alice 的合约无法与Bob的合约互动。', '为定义的ʻERC621`函数设置适当的返回值和vtypes。'], [32, 'erc721-interface', '检查错误的ERC721接口', '中危', 'exactly', '通过', '“ ERC721”功能的返回值不正确。 与这些功能交互的，solidity 版本> 0.4.22的合同将无法执行，因为缺少返回值。', 'contract Token{<br/>&#160;&#160;&#160;&#160;function ownerOf(uint256 _tokenId) external view returns (bool);<br/>&#160;&#160;&#160;&#160;//...<br/>}', 'Token.ownerOf不返回预期的布尔值。 Bob部署令牌。 Alice 创建了一个与之交互的合约，但采用了正确的`ERC721`接口实现。Alice 的合约无法与Bob的合约互动。', '为定义的ʻERC721`函数设置适当的返回值和vtypes。'], [33, 'erc777-interface', '检查错误的ERC777接口', '中危', 'exactly', '通过', '“ ERC777”功能的返回值不正确。 与这些功能交互的，solidity 版本> 0.4.22的合同将无法执行，因为缺少返回值。', 'contract Token{<br/>&#160;&#160;&#160;&#160;function defaultOperators() public view returns (address);<br/>&#160;&#160;&#160;&#160;//...<br/>}', 'Token.defaultOperators不返回预期的布尔值。 Bob部署令牌。 Alice 创建了一个与之交互的合约，但采用了正确的`ERC777`接口实现。Alice 的合约无法与Bob的合约互动。', '为定义的ʻERC777`函数设置适当的返回值和vtypes。'], [34, 'erc875-interface', '检查错误的ERC875接口', '中危', 'exactly', '通过', '“ ERC875”功能的返回值不正确。 与这些功能交互的，solidity 版本> 0.4.22的合同将无法执行，因为缺少返回值。', 'contract Token{<br/>&#160;&#160;&#160;&#160;function balanceOf(address _owner) public view returns (string _balances);<br/>&#160;&#160;&#160;&#160;//...<br/>}', 'Token.balanceOf不返回预期的布尔值。 Bob部署令牌。 Alice 创建了一个与之交互的合约，但采用了正确的`ERC875`接口实现。Alice 的合约无法与Bob的合约互动。', '为定义的ʻERC875`函数设置适当的返回值和vtypes。'], [35, 'incorrect-equality', '检查危险的严格相等', '中危', 'exactly', '通过', '使用严格的平等性（==和!=），攻击者可以轻易操纵这些平等性。具体来说：对手可以通过selfdestruct()或通过挖掘将以太币强制发送到任何地址，从而使严格判断失效。', 'contract Crowdsale{<br/>&#160;&#160;&#160;&#160;function fund_reached() public returns(bool){<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;return this.balance == 100 ether;<br/>&#160;&#160;&#160;&#160;}<br/>}', 'Crowdsale依赖于fund_reached来知道何时停止代币的销售。 Bob发送0.1个以太币。 结果，fund_reached始终为假，而crowdsale永远成立。', '不要使用严格的相等性来确定一个帐户是否有足够的以太币或令牌。'], [36, 'incorrect-signature', '检查不正确的函数签名', '中危', 'exactly', '通过', '在Solidity中，函数签名的定义是：不带有数据位置说明符的基本原型规范表达式，即带有带括号的参数类型列表的函数名。参数类型由一个逗号分隔，而不使用空格。这意味着应该使用uint256和int256而不是uint或int。例如：bytes4(keccak256(<signature>))中，signatrue应该是unit256或int256的，而不是uint或int，要不然长度不够。', 'pragma solidity ^0.5.1;<br/>contract Signature {<br/>&#160;&#160;&#160;&#160;function callFoo(address addr, uint value) public returns (bool) {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;bytes memory data = abi.encodeWithSignature("foo(uint)", value);<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;(bool status, ) = addr.call(data);<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;return status;<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '仔细检查签名函数的参数类型，确保和签名所需的类型一致。'], [37, 'locked-ether', '检查合约以太币是否被锁定', '中危', 'exactly', '通过', '编程为接收以太币的合约（存在payable标识）应实现撤回以太币的方法，即调用transfer（推荐）、send或call.value 至少一次。', 'pragma solidity 0.4.24;<br/>contract Locked{<br/>&#160;&#160;&#160;&#160;function receive() payable public{}<br/>}', '发送到“Locked”的所有以太币都将丢失。', '删除应付款属性或添加提款功能。'], [38, 'mapping-deletion', '删除映射的结构体问题', '中危', 'exactly', '通过', '在包含映射的结构中进行删除不会删除该映射（请参见Solidity文档）。 其余数据可用于破坏合同。', 'struct BalancesStruct{<br/>&#160;&#160;&#160;&#160;address owner;<br/>&#160;&#160;&#160;&#160;mapping(address => uint) balances;<br/>}<br/>mapping(address => BalancesStruct) public stackBalance;<br/>function remove() internal{<br/>&#160;&#160;&#160;&#160; delete stackBalance[msg.sender];<br/>}', 'Remove()删除stackBalance的一项。映射balances永远不会删除，因此remove()无法正常工作。', '使用标签锁，或者先删除映射。'], [39, 'shadowing-abstract', '检查来自抽象合约的状态变量', '中危', 'exactly', '通过', '检测抽象合同中隐藏的状态变量。和shadowing-state不同的是，这里检测父合约中没有使用到的隐藏状态变量。', 'contract BaseContract{<br/>&#160;&#160;&#160;&#160;address owner;<br/>}<br/>contract DerivedContract is BaseContract{<br/>&#160;&#160;&#160;&#160;address owner;<br/>}', 'BaseContract的owner在DerivedContract的隐藏变量中。', '删除状态隐藏变量。'], [40, 'tautology', '检查重言或矛盾', '中危', 'exactly', '通过', '检测重言式或矛盾的表达，即指的是if、while、require、assert条件是永真或永假。', 'contract A {<br/>&#160;&#160;&#160;&#160;function f(uint x) public {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;// ...<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (x >= 0) { // bad -- always true<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;// ...<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;// ...<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function g(uint8 y) public returns (bool) {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;// ...<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;return (y < 512); // bad!<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;// ...<br/>&#160;&#160;&#160;&#160;}<br/>}', 'x是uint256，因此x> = 0将始终为真。y是uint8，因此y <512将始终为真。', '通过更改比较或更改值类型来修复不正确的比较。'], [41, 'boolean-cst', '检查布尔常量的误用', '中危', 'probably', '通过', '检测布尔常量的滥用。Bool变量错误使用，这里是bool变量的运算。', 'contract A {<br/>&#160;&#160;&#160;&#160;function f(uint x) public {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;// ...<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (false) { // bad!<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160; &#160;&#160;&#160;&#160;// ...<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;// ...<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function g(bool b) public returns (bool) {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;// ...<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;return (b || true); // bad!<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;// ...<br/>&#160;&#160;&#160;&#160;}<br/>}', '代码中的布尔常量只有很少的合法用途。 其他用途（在复杂的表达式中，作为条件）表示错误或错误代码的持久性。', '验证并简化条件。'], [42, 'constant-function-state', '检查Constant函数改变状态', '中危', 'probably', '通过', '声明为constant/pure/view的函数会更改状态。在Solidity 0.5之前未强制执行constant/pure/view。从Solidity 0.5开始，对constant/pure/view函数的调用使用STATICCALL操作码，该操作码在状态修改时恢复。 结果是，对标签错误的函数的调用可能会捕获以Solidity 0.5编译的合同。', 'contract Constant{<br/>&#160;&#160;&#160;&#160;uint counter;<br/>&#160;&#160;&#160;&#160;function get() public view returns(uint){<br/>&#160;&#160;&#160;&#160; &#160;&#160;&#160;&#160;counter = counter +1;<br/>&#160;&#160;&#160;&#160; &#160;&#160;&#160;&#160;return counter<br/>&#160;&#160;&#160;&#160;}<br/>}', 'Constant部署为Solidity 0.4.25。 Bob编写了一个智能合约，该合约与Solidity 0.5.0中的Constant交互。 所有对get的调用都会还原，从而破坏了Bob的智能合约执行。', '确保在Solidity 0.5.0之前编译的合约属性正确。'], [43, 'divide-before-multiply', '检查不精确的算术运算顺序', '中危', 'probably', '通过', '实体仅支持整数，因此除法经常会截取；在除法之前执行乘法有时可以避免精度损失，实体整数除法可能会截取。 结果，在除法之前执行乘法可能会降低精度。', 'contract A {<br/>&#160;&#160;&#160;&#160;function f(uint n) public {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;coins = (oldSupply / n) * interest;<br/>&#160;&#160;&#160;&#160;}<br/>}', '如果n大于oldSupply，则coins将为零。 例如，oldSupply = 5; n = 10，interest = 2，coins 将为零。 如果使用（oldSupply * interest / n），则硬币将为1。 通常，通常最好重新安排算术以在除法之前执行乘法，除非较小类型的限制使此操作很危险。', '考虑除法之前对乘法进行运算。'], [44, 'erc20-approve', '检查ERC-20先行攻击（TOD交易序列依赖）', '中危', 'probably', '通过', 'ERC-20的approve函数容易受到攻击。使用先行攻击，可以在更改配额值之前花费已approve的代币。该攻击也是交易序列依赖（TOD）的一种。', 'pragma solidity ^0.4.5;<br/>contract StandardToken is ERC20, BasicToken {<br/>&#160;&#160;&#160;&#160;...<br/>&#160;&#160;&#160;&#160;function approve(address _spender, uint256 _value) public returns (bool) {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;allowed[msg.sender][_spender] = _value;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;Approval(msg.sender, _spender, _value);<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;return true;<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;...<br/>}', '', '在执行approve更改之前，先将数值复位为零，再执行更改操作。'], [45, 'function-problem', '检查合同函数异常终止', '中危', 'probably', '通过', '函数永远只会以revert()等异常状态结束，无法正常执行完后return，说明函数设计出现了问题。', 'contract Functionproblem {<br/>&#160;&#160;&#160;&#160;address owner;<br/>&#160;&#160;&#160;&#160;function bad() { //bad<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;revert();<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '检查合约功能的逻辑结构。'], [46, 'mul-var-len-arguments', '检查具有多个可变长度参数的哈希冲突', '中危', 'probably', '通过', 'abi.encodePacked()在某些情况下，使用多个可变长度参数可能会导致哈希冲突。由于abi.encodePacked()所有元素都按顺序打包，而不管它们是否属于数组，因此可以在数组之间移动元素，并且只要所有元素的顺序相同，它将返回相同的编码。在签名验证的情况下，攻击者可以通过修改前一个函数调用中元素的位置来有效地绕过授权，从而利用此漏洞。通过abi.encodePacked()进行身份验证重放，因为encodePacked(a,b)中如果a和b都是变长数组，则可以把a的最后一个，加到b的第一个，使总顺序不变，就可以生成同样的值。', 'contract Mulvarlenarguments {<br/>&#160;&#160;&#160;&#160;function addUsers(<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;address[] calldata admins,<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;address[] calldata regularUsers,<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;bytes calldata signature<br/>&#160;&#160;&#160;&#160;)<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;external<br/>&#160;&#160;&#160;&#160;{ <br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;bytes32 hash = keccak256(abi.encodePacked(admins, regularUsers));<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;address signer = hash.toEthSignedMessageHash().recover(signature);<br/>&#160;&#160;&#160;&#160;}<br/>}', '', 'abi.encodePacked()的参数应尽可能长，并且尽量避免可变数组。'], [47, 'reentrancy-no-eth', '检查重入漏洞（无以太币盗窃）', '中危', 'probably', '通过', '检查有重入（存在先读，后写这种情况），但是没有eth的转移。', 'function bug(){<br/>&#160;&#160;&#160;&#160;require(not_called);<br/>&#160;&#160;&#160;&#160;if( ! (msg.sender.call() ) ){<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;throw;<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;not_called = False;<br/>}', '', '应用check-effects-interactions模式。'], [48, 'reused-constructor', '检查集成合约中构造函数冲突问题', '中危', 'probably', '通过', '检测是否使用来自相同继承层次结构中两个不同位置的参数调用相同的基本构造函数。', 'pragma solidity ^0.4.0;<br/>contract A{<br/>&#160;&#160;&#160;&#160;uint num = 5;<br/>&#160;&#160;&#160;&#160;constructor(uint x) public{<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;num += x;<br/>&#160;&#160;&#160;&#160;}<br/>}<br/>contract B is A{<br/>&#160;&#160;&#160;&#160;constructor() A(2) public { /* ... */ }<br/>}<br/>contract C is A {<br/>&#160;&#160;&#160;&#160;constructor() A(3) public { /* ... */ }<br/>}<br/>contract D is B, C {<br/>&#160;&#160;&#160;&#160;constructor() public { /* ... */ }<br/>}<br/>contract E is B {<br/>&#160;&#160;&#160;&#160;constructor() A(1) public { /* ... */ }<br/>}', 'A的构造函数在D和E中多次调用：D继承自B和C，两者都构成A。E仅从B继承，但B和E构造A。', '删除重复的构造函数调用。'], [49, 'tx-origin', '检查tx.origin的危险使用', '中危', 'probably', '通过', '如果合法用户与恶意合约进行交互，则基于tx.origin的保护会被恶意合约滥用。', 'contract TxOrigin {<br/>&#160;&#160;&#160;&#160;address owner = msg.sender;<br/>&#160;&#160;&#160;&#160;function bug() {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;require(tx.origin == owner);<br/>&#160;&#160;&#160;&#160;}<br/>}', 'Bob是TxOrigin的所有者。 Bob调用Eve的合约。 Eve的合约称为TxOrigin，并绕过 tx.origin的保护。', '不要使用`tx.origin`进行授权。'], [50, 'typographical-error', '检查是否存在编写错误（=+）', '中危', 'probably', '通过', '例如，当已定义操作的意图是将一个数字与一个变量求和（+ =），但意外地以错误的方式（= +）定义了印刷错误时，就会出现印刷错误，而这恰好是有效的操作员。而不是计算总和，而是再次初始化变量。', 'pragma solidity ^0.4.24;<br/>contract TypoOneCommand {<br/>&#160;&#160;&#160;&#160;uint numberOne = 1;<br/>&#160;&#160;&#160;&#160;string numberstring = "";<br/>&#160;&#160;&#160;&#160;function alwaysOne() public {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;numberOne =+ 1; //bad<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function alwaysOne_bad() public {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;numberOne =- 1; //bad<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '仔细检查运算符号，如果发现有误请及时更改。'], [51, 'unchecked-lowlevel', '检查未审查的低级别调用calls', '中危', 'probably', '通过', '低级调用外部合约失败，而没有对返回值进行判断。同时发送以太币时，请检查返回值并处理错误。', 'contract MyConc{<br/>&#160;&#160;&#160;&#160;function my_func(address payable dst) public payable{<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;dst.call.value(msg.value)("");<br/>&#160;&#160;&#160;&#160;}<br/>}', '不检查低级调用的返回值，因此，如果调用失败，则以太币将被锁定在合约中。 如果使用低级别调用阻止区块操作，请考虑记录失败的调用。', '确保检查或记录低级调用的返回值。'], [52, 'unchecked-send', '检查未审查的send', '中危', 'probably', '通过', '和unchecked-lowlevel类似，这里说明的是没有对send、Highlevelcall的返回值进行检测。', 'contract MyConc{<br/>&#160;&#160;&#160;&#160;function my_func(address payable dst) public payable{<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;dst.send(msg.value);<br/>&#160;&#160;&#160;&#160;}<br/>}', '未检查send的返回值，因此，如果发送失败，则以太币将被锁定在合约中。 如果使用send来阻止区块操作，请考虑记录失败的send。', '确保已检查或记录了send的返回值。'], [53, 'uninitialized-local', '检查未初始化的局部变量', '中危', 'probably', '通过', '检查没有初始化的local变量。', 'contract Uninitialized is Owner{<br/>&#160;&#160;&#160;&#160;function withdraw() payable public onlyOwner{<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;address to;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;to.transfer(this.balance)<br/>&#160;&#160;&#160;&#160;}<br/>}', 'Bob调用transfer。 结果，所有以太币被发送到地址“ 0x0”并丢失。', '初始化所有变量。 如果要将变量初始化为零，即将其设置为零。'], [54, 'unused-return', '检查是否存在未使用的返回值', '中危', 'probably', '通过', '调用的返回值未存储在局部变量或状态变量中，即调用函数可能没有产生任何效果。', 'contract MyConc{<br/>&#160;&#160;&#160;&#160;using SafeMath for uint;   <br/>&#160;&#160;&#160;&#160;function my_func(uint a, uint b) public{<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;a.add(b);<br/>&#160;&#160;&#160;&#160;}<br/>}', 'MyConc会调用SafeMath的add，但是不会将结果存储在a中。 结果，计算没有效果。', '确保使用了函数调用的所有返回值。'], [55, 'writeto-arbitrarystorage', '检查是否可以写入任意存储位置', '中危', 'probably', '通过', '智能合约的数据（例如，存储合约的所有者）被永久存储在EVM级别的某个存储位置（即，密钥或地址）。合同负责确保只有授权的用户或合同帐户才能写入敏感的存储位置。如果攻击者能够写入合同的任意存储位置，则可以轻松绕开授权检查。这可能使攻击者破坏存储空间。例如，通过覆盖存储合同所有者地址的字段。', 'contract Map {<br/>&#160;&#160;&#160;&#160;address public owner;<br/>&#160;&#160;&#160;&#160;uint256[] map;<br/>&#160;&#160;&#160;&#160;function set(uint256 key, uint256 value) public {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (map.length <= key) {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;map.length = key + 1;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;map[key] = value;<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '严格判断存储变量的位置。'], [56, 'costly-loop', '检查过于昂贵的循环', '中危', 'possibly', '通过', '以太坊是一个非常资源受限的环境。每个计算步骤的价格比集中式提供商的价格高几个数量级。此外，以太坊矿工对区块中消耗的天然气总量施加了限制。如果array.length足够大，则该函数超出了限制气体限制，并且永远不会确认调用该函数的事务。如果外部参与者影响array.length，这将成为一个安全问题。 ', 'pragma solidity 0.4.24;<br/>contract PriceOracle {<br/>&#160;&#160;&#160;&#160;address internal owner;<br/>&#160;&#160;&#160;&#160;address[] public subscribers;<br/>&#160;&#160;&#160;&#160;mapping(address => uint) balances;<br/>&#160;&#160;&#160;&#160;uint internal constant PRICE = 10**15;<br/>&#160;&#160;&#160;&#160;function subscribe() payable external{<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;subscribers.push(msg.sender);<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;balances[msg.sender] += msg.value;<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function setPrice(uint price) external {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;require(msg.sender == owner);<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;bytes memory data = abi.encodeWithSelector(SIGNATURE, price);<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;for (uint i = 0; i < subscribers.length; i++) {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if(balances[subscribers[i]] >= PRICE) {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;balances[subscribers[i]] -= PRICE;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;subscribers[i].call.gas(50000)(data);<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '请仔细检查循环的动态数组，如果发现可被攻击者利用，请对其进行更改，以免合约因为执行太多循环而导致gas溢出回滚。'], [57, 'shift-parameter-mixup', '检查可反转的移位操作', '中危', 'possibly', '通过', '检测移位操作中的值是否被反转。', 'contract C {<br/>&#160;&#160;&#160;&#160;function f() internal returns (uint a) {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;assembly {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;a := shr(a, 8)<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;}<br/>}', 'shift语句将常数8右移一位。', '交换参数顺序。'], [58, 'shadowing-builtin', '检查内置符号的隐藏', '低危', 'exactly', '通过', '使用局部变量，状态变量，函数，修饰符或事件来检测隐藏的内置符号。', 'pragma solidity ^0.4.24;<br/>contract Bug {<br/>&#160;&#160;&#160;&#160;uint now; // Overshadows current time stamp.<br/>&#160;&#160;&#160;&#160;function assert(bool condition) public {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;// Overshadows built-in symbol for providing assertions.<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function get_next_expiration(uint earlier_time) private returns (uint) {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;return now + 259200; // References overshadowed timestamp.<br/>&#160;&#160;&#160;&#160;}<br/>}', 'now被定义为状态变量，并且隐藏内置符号 now。 函数assert使内置的assert功能黯然失色。 这样对这些内置符号的使用都可能导致意外结果。', '重命名隐藏内置符号的局部变量，状态变量，函数，修饰符和事件。'], [59, 'shadowing-function', '检查函数隐藏', '低危', 'exactly', '通过', '检测被隐藏的函数。', 'contract BaseContract{<br/>&#160;&#160;&#160;&#160;function aa(uint a,uint b) returns (uint) {<br/>&#160;&#160;&#160;&#160;return a;<br/>&#160;&#160;&#160;&#160;}<br/>}<br/>contract DerivedContract is BaseContract{<br/>&#160;&#160;&#160;&#160;function aa(uint a,uint b) returns (uint) {<br/>&#160;&#160;&#160;&#160;return b;<br/>&#160;&#160;&#160;&#160;}<br/>}', 'BaseContract的aa函数不起作用。', '更改隐藏或被隐藏的函数名称。'], [60, 'shadowing-local', '检查局部变量隐藏', '低危', 'exactly', '通过', '检测被隐藏的local变量。', 'pragma solidity ^0.4.24;<br/>contract Bug {<br/>&#160;&#160;&#160;&#160;uint owner;<br/>&#160;&#160;&#160;&#160;function sensitive_function(address owner) public {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;// ...<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;require(owner == msg.sender);<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function alternate_sensitive_function() public {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;address owner = msg.sender;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;// ...<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;require(owner == msg.sender);<br/>&#160;&#160;&#160;&#160;}<br/>}', 'sensitive_function.owner隐藏了Bug.owner。 结果，在sensitive_function中使用owner可能是不正确的。', '重命名隐藏或被隐藏的局部变量。'], [61, 'transfer-to-zeroaddress', '检查取款地址是否为0x0', '低危', 'exactly', '通过', '在transfer、transferFrom、transferOwnership等敏感函数中，用户操作不可逆，所以建议开发者在这些函数实现中增加目标地址非零检查，避免用户误操作导致用户权限丢失和财产损失。如果转移到0x00，则以太币很难再进行回转，从而造成以太币丢失。', 'contract Transfertozeroaddress {<br/>&#160;&#160;&#160;&#160;address owner;<br/>&#160;&#160;&#160;&#160;function bad() {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;address aa = 0x0;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;aa.transfer(msg.value);<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function good() {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;address aa = 0x0;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if(aa != 0x0) {revert();}<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;aa.transfer(msg.value);<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '请检查以太币转移的对象是否为零地址。'], [62, 'uninitialized-fptr-cst', '检测构造函数中未初始化的指针', '低危', 'exactly', '通过', 'solc版本0.4.5-0.4.26和0.5.0-0.5.8包含一个编译器错误，导致在构造函数中调用未初始化的函数指针时导致意外行为。', 'contract bad0 {<br/>&#160;&#160;&#160;&#160;constructor() public {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* Uninitialized function pointer */<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;function(uint256) internal returns(uint256) a;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;a(10);<br/>&#160;&#160;&#160;&#160;}<br/>}', '调用a(10)将导致意外行为，因为函数指针a未在构造函数中初始化。', '在调用之前初始化函数指针。另外，尽可能避免使用函数指针。这里需要注意的是在构造函数中调用未初始化的指针，编译器的漏洞。'], [63, 'variable-scope', '检查变量的声明问题', '低危', 'exactly', '通过', '在结束声明之前检测变量的可能用法（因为它是后来声明的，或者是在另一个作用域中声明的）。', "contract C {<br/>&#160;&#160;&#160;&#160;function f(uint z) public returns (uint) {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;uint y = x + 9 + z; // 'z' is used pre-declaration<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;uint x = 7;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (z % 2 == 0) {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;uint max = 5;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;// ...<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;// 'max' was intended to be 5, but it was mistakenly declared in a scope and not assigned (so it is zero).<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;for (uint i = 0; i < max; i++) {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;x += 1;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;return x;<br/>&#160;&#160;&#160;&#160;}<br/>}", '在上述情况下，变量x会在声明之前使用，这可能会导致意想不到的后果。 此外，for循环使用变量max，该变量在以前可能无法始终到达的先前作用域中声明。 如果用户在任何预期的声明分配之前错误地使用了变量，则可能导致意想不到的后果。 它还可能指示用户打算引用其他变量。即max可能无法正常声明，那么在后面的调用时会产生意外的情况。', '在对变量进行任何使用之前，请先移动所有变量声明，并确保是否无条件使用变量声明不会取决于某些条件声明。'], [64, 'void-cst', '检查对未实现构造函数的调用', '低危', 'exactly', '通过', '检测对未实现的构造函数的调用，调用的合约没有声明构造函数。', 'contract A{}<br/>contract B is A{<br/>&#160;&#160;&#160;&#160;constructor() public A(){}<br/>}', '在读取B的构造函数定义时，我们可以假定A()启动了合约，但是没有代码被执行。', '删除对未实现构造函数的调用。'], [65, 'incorrect-modifier', '检查_或还原不能正常执行的Modifier', '低危', 'exactly', '通过', '如果修饰符不执行_或还原，则函数的执行将返回默认值，这可能会误导调用者。', 'contract A{<br/>&#160;&#160;&#160;&#160;modidfier myModifier(){<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if(false){<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;   _;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function set() myModifier returns(uint){<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;return 0;<br/>&#160;&#160;&#160;&#160;}<br/>}', 'myModifier将导致set函数不能执行。', '检查修饰符中的所有路径是否都可以执行_或还原。'], [66, 'assemblycall-rewrite', '检查输出覆盖输入的assemblycall', '低危', 'probably', '通过', '危险使用CALL系列的内联汇编指令 assemblyCall，该指令会用输出覆盖输入。如果将任意地址称为返回值，则返回值可能与预期值不同。', 'contract MixinSignatureValidator {<br/>&#160;&#160;&#160;&#160;function isValidWalletSignature(<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;bytes32 hash,<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;address walletAddress,<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;bytes signature<br/>&#160;&#160;&#160;&#160;)internal view returns (bool isValid){<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;assembly {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;let cdStart := add(calldata, 32)<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;let success := staticcall(<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;gas,              // forward all gas<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;walletAddress,    // address of Wallet contract<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;cdStart,          // pointer to start of input<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;mload(calldata),  // length of input<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;cdStart,          // write output over input<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;32                // output size is 32 bytes<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;)<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;return isValid;<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '请仔细检查assemblycall使用的地方，确保不能覆盖输入造成错误，否则不使用该指令。'], [67, 'block-other-parameters', '检查block.number等变量的危险使用', '低危', 'probably', '通过', '合同通常需要访问时间值以执行某些类型的功能。block.number可以使您了解当前时间或时间增量，但是，在大多数情况下使用它们并不安全。block.number以太坊的区块时间通常约为14秒，因此可以预测区块之间的时间增量。但是，封锁时间不是固定的，并且由于各种原因（例如，叉子重组和难度系数）可能会发生变化。由于块时间可变，block.number因此也不应该依赖于精确的时间计算。生成随机数的能力在各种应用中都非常有用。一个明显的例子是赌博DApp，其中使用伪随机数生成器选择获胜者。但是，在以太坊中创建足够强大的随机性源非常具有挑战性。使用blockhash，block.difficulty以及其他领域也是不安全的，因为它们是由矿工控制。如果赌注很高，那么该矿工可以在短时间内通过租用硬件来开采大量区块，选择需要获得区块哈希值才能获胜的区块，然后丢弃所有其他区块。', 'contract Otherparameters{<br/>&#160;&#160;&#160;&#160;event Number(uint);<br/>&#160;&#160;&#160;&#160;event Coinbase(address);<br/>&#160;&#160;&#160;&#160;event Difficulty(uint);<br/>&#160;&#160;&#160;&#160;event Gaslimit(uint);<br/>&#160;&#160;&#160;&#160;function bad0() external{<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;require(block.number == 20);<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;require(block.coinbase == msg.sender);<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;require(block.difficulty == 20);<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;require(block.gaslimit == 20);<br/>&#160;&#160;&#160;&#160;}<br/>}', 'Bob的合同的随机性依赖于block.number等。 Eve是一名矿工，操纵block.number等来利用Bob的合约。', '避免依赖于block.number等可被矿工操纵的数据。'], [68, 'calls-loop', '检查循环中的外部调用call', '低危', 'probably', '通过', 'ETH是循环传输的。如果至少有一个地址无法接收ETH（例如，它是具有默认回退函数的合约），则整个交易将被还原。', 'contract CallsInLoop{<br/>&#160;&#160;&#160;&#160;address[] destinations;<br/>&#160;&#160;&#160;&#160;constructor(address[] newDestinations) public{<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;destinations = newDestinations;<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function bad() external{<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;for (uint i=0; i < destinations.length; i++){<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;destinations[i].transfer(i);<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;}<br/>}', '如果目的地址之一被回退函数还原，则bad()将全部还原，所以所有工作都白费了。', '调用外部合约尽量避免在循环中调用，可以使用pull over push策略。'], [69, 'events-access', '检查关键访问控制参数的丢失', '低危', 'probably', '通过', '检测关键访问控制参数的丢失事件。', 'contract C {<br/>&#160;&#160;&#160;&#160;modifier onlyAdmin {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (msg.sender != owner) throw;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;_;<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function updateOwner(address newOwner) onlyAdmin external {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;owner = newOwner;<br/>&#160;&#160;&#160;&#160;}<br/>}', 'updateOwner()没有事件，因此很难在链下对这些权限极高的操作进行跟踪。', '事件记录关键参数的更改。'], [70, 'events-maths', '检测关键算术参数的丢失', '低危', 'probably', '通过', '检测关键算术参数的丢失事件。', 'contract C {<br/>&#160;&#160;&#160;&#160;modifier onlyOwner {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (msg.sender != owner) throw;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;_;<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function setBuyPrice(uint256 newBuyPrice) onlyOwner public {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;buyPrice = newBuyPrice;<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function buy() external {<br/>&#160;&#160;&#160;&#160; ... // buyPrice is used to determine the number of tokens purchased<br/>&#160;&#160;&#160;&#160;}&#160;&#160;&#160;&#160;<br/>}', 'setBuyPrice没有记录事件，因此很难在链下跟踪购买价格的更改。', '事件记录关键参数的更改。'], [71, 'extcodesize-invoke', '检查Extcodesize的调用', '低危', 'probably', '通过', 'extcodesize在合约部署的时候为零，攻击者可以在自己的构造函数中调用受害合约，这个时候使用extcodesize验证是无效的。', "pragma solidity ^0.4.23;<br/>contract ExtCodeSize {<br/>&#160;&#160;&#160;&#160;// This contract would be 'hacked' if the address saved here is a contract address<br/>&#160;&#160;&#160;&#160;address public thisIsNotAContract;<br/>&#160;&#160;&#160;&#160;function aContractCannotCallThis() public {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;uint codeSize;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;assembly { codeSize := extcodesize(caller) }<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;// If extcodesize returns 0, it means the caller's code length is 0, so, it is not a contract...<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;// or maybe not<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;require(codeSize == 0);<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;thisIsNotAContract = msg.sender;<br/>&#160;&#160;&#160;&#160;}<br/>}", '', '尽量避免使用extcodesize对账户等于零进行判断，可换成不等于零，对相反的情况进行判断。'], [72, 'fllback-outofgas', '检查回退函数是否太过复杂', '低危', 'probably', '通过', '合约的fallback函数通常用以接收一笔eth转账（转账失败后还原取款操作），但如果在fallback里实现过于复杂的逻辑，可能会将gas耗尽，导致转账不成功。', 'contract C {<br/>&#160;&#160;&#160;&#160;function f(uint a, uint b) public{<br/>&#160;&#160;&#160;&#160;uint a = 0;<br/>&#160;&#160;&#160;&#160;do {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;continue;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;a++;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;} while(a<10);<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '请简化回退函数。'], [73, 'incorrect-blockhash', '检查Blockhash函数的错误使用', '低危', 'probably', '通过', 'blockhash函数只返回最后256个块的非零值。此外，对于当前块，它总是返回0，即blockhash(块编号)总是等于0。不能查询当前块的hash，只能查询最近的256个块，否则只返回值0。', 'pragma solidity 0.4.25;<br/>contract MyContract {<br/>&#160;&#160;&#160;&#160;function currentBlockHash() public view returns(bytes32) {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;return blockhash(block.number);<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '在使用blockhash函数时，请确保使用正确。'], [74, 'incorrect-inheritance-order', '检查继承变量是否冲突', '低危', 'probably', '通过', '实体支持多种继承，这意味着一个合同可以继承多个合同。多重继承引入了称为钻石的歧义问题：如果两个或多个基本合同定义了相同的功能，则在子合同中应调用哪个？Solidity通过使用反向C3线性化来解决这种歧义，该线性化在基础合约之间设置了优先级。这样，基本合同具有不同的优先级，因此继承顺序很重要。忽略继承顺序可能导致意外行为。注意合约继承的顺序，因为继承的合约可能有变量或函数的重叠，而继承顺序决定了合约的级别，进而决定了使用哪个合约中的重叠变量和函数。', 'contract A {<br/>&#160;&#160;&#160;&#160;address owner;<br/>}<br/>contract B {<br/>&#160;&#160;&#160;&#160;address owner;<br/>}<br/>contract C is B,A{}', '', '检查继承顺序。'], [75, 'integer-overflow', '检查整数是否存在溢出', '低危', 'probably', '通过', '当算术运算达到类型的最大或最小大小时，将发生上溢/下溢。例如，如果一个数字以uint8类型存储，则意味着该数字以8位无符号数字存储，范围从0到2 ^ 8-1。在计算机编程中，当算术运算试图创建一个数值时，会发生整数溢出，该数值可以用给定的位数表示-大于最大表示值或小于最小表示值。', 'contract Intergeroverflow{<br/>&#160;&#160;&#160;&#160;function bad() {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;uint a;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;uint b;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;uint c = a + b;<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '使用Safemath进行整数运算，或验证计算值。'], [76, 'missing-zero-check', '检查零地址的使用', '低危', 'probably', '通过', '检查零地址的验证。', 'contract C {<br/>&#160;&#160;&#160;&#160;modifier onlyAdmin {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (msg.sender != owner) throw;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;_;<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function updateOwner(address newOwner) onlyAdmin external {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;owner = newOwner;<br/>&#160;&#160;&#160;&#160;}<br/>}', 'Bob在未指定newOwner的情况下调用updateOwner，因此Bob失去了合约的所有权。', '检查地址不为零。'], [77, 'reentrancy-benign', '检查和连续调用效果相同的重入漏洞', '低危', 'probably', '通过', '检测到重入错误，这里主要说明的是该重入造成的效果和连续调用两次函数相同。', 'function callme(){<br/>&#160;&#160;&#160;&#160;if( ! (msg.sender.call()() ) ){<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;throw;<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;counter += 1<br/>}', 'callme包含可重入漏洞。但可重入是良性的，因为它的利用与两个连续的调用具有相同的效果。', '应用check-effects-interactions模式。'], [78, 'reentrancy-events', '检查可重入漏洞导致事件乱序（call等）', '低危', 'probably', '通过', '检测到重入错误，这里仅报告可导致乱序事件的重入漏洞。', 'function bug(Called d){<br/>&#160;&#160;&#160;&#160;counter += 1;<br/>&#160;&#160;&#160;&#160;d.f();<br/>&#160;&#160;&#160;&#160;emit Counter(counter);<br/>}', '如果重入d()，则会以错误的顺序显示Counter事件，这可能会导致第三方出现问题。', '应用check-effects-interactions模式。'], [79, 'timestamp', '检查block.timestamp的危险使用', '低危', 'probably', '通过', '合约中存在与block.timestamp或now进行严格比较的情况，矿工可以通过block.timestamp受益。', 'contract Timestamp{<br/>&#160;&#160;&#160;&#160;event Time(uint);<br/>&#160;&#160;&#160;&#160;modifier onlyOwner {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;require(block.timestamp == 0);<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;_;  <br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function bad0() external{<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;require(block.timestamp == 0);<br/>&#160;&#160;&#160;&#160;}<br/>}', 'Bob的合约依赖于block.timestamp的随机性。Eve是一名矿工，操纵block.timestamp来利用Bob的合同。', '避免依赖于block.timestamp。'], [80, 'signature-malleability', '检查签名中是否包含已有签名', '低危', 'possibly', '通过', '以太坊合同中的加密签名系统的实现通常假定签名是唯一的，但是可以在不拥有私钥的情况下更改签名，并且该签名仍然有效。EVM规范定义了几个所谓的“预编译”合约，其中一个合约ecrecover执行椭圆曲线公钥恢复。恶意用户可以稍微修改三个值v，r和s来创建其他有效签名。如果签名是已签名消息哈希的一部分，则在合同级别执行签名验证的系统可能会受到攻击。恶意用户可以创建有效的签名，以重放以前签名的消息。签名中不能包含已有签名 ，容易受到攻击。', 'function transfer(bytes _signature,address _to,uint256 _value,uint256 _gasPrice,uint256 _nonce) public returns (bool){<br/>&#160;&#160;&#160;&#160;bytes32 txid = keccak256(abi.encodePacked(getTransferHash(_to, _value, _gasPrice, _nonce), _signature)); //bad<br/>&#160;&#160;&#160;&#160;require(!signatureUsed[txid]);<br/>&#160;&#160;&#160;&#160;address from = recoverTransferPreSigned(_signature, _to, _value, _gasPrice, _nonce);<br/>&#160;&#160;&#160;&#160;require(balances[from] > _value);<br/>&#160;&#160;&#160;&#160;balances[from] -= _value;<br/>&#160;&#160;&#160;&#160;balances[_to] += _value;<br/>&#160;&#160;&#160;&#160;signatureUsed[txid] = true;<br/>}', '', '签名不应包含现有签名。'], [81, 'assembly', '检查assembly的不安全使用', '提醒', 'exactly', '通过', '内联汇编是从低级别访问以太坊虚拟机，这导致Solidity的几个重要的安全功能被放弃了。', 'function recover(bytes32 hash, bytes sig) public pure returns (address) {<br/>&#160;&#160;&#160;&#160;bytes32 r;<br/>&#160;&#160;&#160;&#160;bytes32 s;<br/>&#160;&#160;&#160;&#160;uint8 v;<br/>&#160;&#160;&#160;&#160;// Divide the signature in r, s and v variables<br/>&#160;&#160;&#160;&#160;assembly {<br/>&#160;&#160;&#160;&#160; &#160;&#160;&#160;&#160;r := mload(add(sig, 32))<br/>&#160;&#160;&#160;&#160; &#160;&#160;&#160;&#160;s := mload(add(sig, 64))<br/>&#160;&#160;&#160;&#160; &#160;&#160;&#160;&#160;v := byte(0, mload(add(sig, 96)))<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '仔细检查内联汇编指令，确保能够安全地运行，否则需要对其更换。'], [82, 'assert-state-change', '检查assert()的错误使用', '提醒', 'exactly', '通过', '错误使用assert()。请参阅Solidity最佳做法。', 'contract A {<br/>  uint s_a;<br/>  function bad() public {<br/>&#160;&#160;&#160;&#160;assert((s_a += 1) > 10);<br/>  }<br/>}', 'Bad()中的assert在检查条件时会递增状态变量s_a。', '使用require来修改状态的不变式。'], [83, 'delete-dynamic-arrays', '检查对动态存储数组的删除', '提醒', 'exactly', '通过', '对动态大小的存储数组应用delete或.length=0可能会导致Out-of-Gas异常。因为会遍历数组所有的数据，可能会超了gas。', 'contract C {<br/>&#160;&#160;&#160;&#160;uint[] amounts;<br/>&#160;&#160;&#160;&#160;address payable[] addresses;<br/>&#160;&#160;&#160;&#160;function collect(address payable to) external payable {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;amounts.push(msg.value);<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;addresses.push(to);<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function pay() external {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;uint length = amounts.length;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;delete amounts;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;delete addresses;<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '仔细检查动态数组的删除或直接更改数组length的操作，查看数组是否可被攻击者任意添加。'], [84, 'deprecated-standards', '检查Solidity弃用的指令', '提醒', 'exactly', '通过', '不推荐使用Solidity中的几个函数和运算符。使用它们会降低代码质量。在新的主要版本的Solidity编译器中，不建议使用的函数和运算符可能会导致副作用和编译错误。0.5.0以后Solidity弃用的结构：years, sha3, suicide, throw 和 constant 函数。', 'contract ContractWithDeprecatedReferences {<br/>&#160;&#160;&#160;&#160;// Deprecated: Change block.blockhash() -> blockhash()<br/>&#160;&#160;&#160;&#160;bytes32 globalBlockHash = block.blockhash(0);<br/>&#160;&#160;&#160;&#160;// Deprecated: Change constant -> view<br/>&#160;&#160;&#160;&#160;function functionWithDeprecatedThrow() public constant {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;// Deprecated: Change msg.gas -> gasleft()<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if(msg.gas == msg.value) {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;// Deprecated: Change throw -> revert()<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;throw;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;// Deprecated: Change constant -> view<br/>&#160;&#160;&#160;&#160;function functionWithDeprecatedReferences() public constant {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;// Deprecated: Change sha3() -> keccak256()<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;bytes32 sha3Result = sha3("test deprecated sha3 usage");<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;// Deprecated: Change callcode() -> delegatecall()<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;address(this).callcode();<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;// Deprecated: Change suicide() -> selfdestruct()<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;suicide(address(0));<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '替换所有不能使用的变量或函数（特别是在0.5.0以后）。'], [85, 'erc20-indexed', '检查ERC20事件参数缺少indexed', '提醒', 'exactly', '通过', 'ERC-20令牌标准的“Transfer”和“Approval”事件的地址参数应当包含索引indexed。', 'contract ERC20Bad {<br/>&#160;&#160;&#160;&#160;// ...<br/>&#160;&#160;&#160;&#160;event Transfer(address from, address to, uint value);<br/>&#160;&#160;&#160;&#160;event Approval(address owner, address spender, uint value);<br/>&#160;&#160;&#160;&#160;// ...<br/>}', '按照ERC20规范的定义，Transfer和Approval事件的前两个参数应带有 indexed关键字。如果不包含这些关键字，则将参数数据排除在事务/块的bloom筛选器中，因此，外部工具搜索这些参数可能会忽略它们，并且无法索引此令牌合约中的日志。', '根据ERC20规范，将indexed关键字添加到对应关键字的事件参数中。'], [86, 'erc20-throw', '检查erc20是否有抛出异常', '提醒', 'exactly', '通过', 'ERC-20代币标准的函数在以下特殊情况下应该抛出：如果_from帐户余额中没有足够的代币来花费，则应该抛出；除非_from帐户通过某种机制故意授权了消息的发送者，否则transferFrom应当抛出。', 'contract SomeToken {<br/>&#160;&#160;&#160;&#160;mapping(address => uint256) balances;<br/>&#160;&#160;&#160;&#160;event Transfer(address indexed _from, address indexed _to, uint256 _value);<br/>&#160;&#160;&#160;&#160;function transfer(address _to, uint _value) public returns (bool) {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (_value > balances[msg.sender] || _value > balances[_to] + _value) {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;return false;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;balances[msg.sender] = balances[msg.sender] - _value;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;balances[_to] = balances[_to] + _value;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;emit Transfer(msg.sender, _to, _value);<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;return true;<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '在ERC-20代币中添加相应的throw方法。'], [87, 'length-manipulation', '检查数组长度的不安全操作', '提醒', 'exactly', '通过', '动态数组的长度直接更改。在这种情况下，可能会出现巨大的阵列，并且可能导致存储重叠攻击（与存储中其他数据的冲突）。length"的操作有： =、 +=、 -=、*=、 /=、--等。', 'pragma solidity 0.4.24;<br/>contract dataStorage {<br/>&#160;&#160;&#160;&#160;uint[] public data;<br/>&#160;&#160;&#160;&#160;function writeData(uint[] _data) external {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;for(uint i = data.length; i < _data.length; i++) {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;data.length++;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;data[i]=_data[i];<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '仔细检查动态数组的操作，查看数组是否可被攻击者任意添加。'], [88, 'low-level-calls', '检查低级别的调用', '提醒', 'exactly', '通过', '标注低级别的call、delegatecall和callcode等方法，因为这些方法容易被攻击者利用。', 'contract Sender {<br/>&#160;&#160;&#160;&#160;address owner;<br/>&#160;&#160;&#160;&#160;modifier onlyceshi() {<br/>&#160;&#160;&#160;&#160;owner.callcode(bytes4(keccak256("inc()")));<br/>&#160;&#160;&#160;&#160;_;<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function send(address _receiver) payable external {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;_receiver.call.value(msg.value).gas(7777)("");<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function sendceshi(address _receiver) payable external {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if(_receiver.call.value(msg.value).gas(7777)("")){<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;revert();<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '避免低级调用。 检查调用是否成功。 如果调用是签订合约，请检查代码是否存在。'], [89, 'msgvalue-equals-zero', '检查msg.value与零的判断', '提醒', 'exactly', '通过', 'msg.value==0检查条件在大多数情况下没有意义。', 'contract A{<br/>&#160;&#160;&#160;&#160;address owner;<br/>&#160;&#160;&#160;&#160;mapping(address => uint256) balances;<br/>&#160;&#160;&#160;&#160;constructor() {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;owner = msg.sender;<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function B() return (uint256){<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if(masg.value == 0) {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;return 0;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;balances[msg.sender] += msg.value;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;return balances[msg.sender];<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '查看该检查条件是否真的需要，不需要的话删掉可以节约gas。'], [90, 'naming-convention', '检查命名是否遵循Solidity格式', '提醒', 'exactly', '通过', '检查合约中编写的命名是否规范，因为命名杂乱不便于理解和管理。', 'contract naming {<br/>&#160;&#160;&#160;&#160;enum Numbers {ONE, TWO}<br/>&#160;&#160;&#160;&#160;enum numbers {ONE, TWO}<br/>&#160;&#160;&#160;&#160;uint constant MY_CONSTANT = 1;<br/>&#160;&#160;&#160;&#160;uint constant MY_other_CONSTANT = 2;<br/>&#160;&#160;&#160;&#160;uint Var_One = 1;<br/>&#160;&#160;&#160;&#160;uint varTwo = 2;<br/>}', '', '请遵循Solidity [命名规范]（https://solidity.readthedocs.io/en/v0.4.25/style-guide.html#naming-conventions）。'], [91, 'pragma', '检查是否声明了多个编译版本', '提醒', 'exactly', '通过', '合约中使用了不同的Solidity版本（两个以上）会使编译器不能很好的按照我们的想法进行编译。', 'pragma solidity ^0.4.23;<br/>pragma solidity ^0.4.24;', '', '使用一个Solidity版本。'], [92, 'solc-version', '检查不正确的Solidity版本', '提醒', 'exactly', '通过', 'Solidity源文件指示可以使用它们编译的编译器的版本。建议指示明确版本，因为将来的编译器版本可能会以开发人员无法预见的方式处理某些语言构造。', 'pragma solidity >=0.4.23 <0.4.25;', '', '使用允许任何这些版本的简单编译指示版本。 考虑使用最新版本的Solidity进行测试。Solidity版本推荐：0.5.11-0.5.13、0.5.15-0.5.17、0.6.8、0.6.10-0.6.11。'], [93, 'unimplemented-functions', '检查合约中未被重载的函数', '提醒', 'exactly', '通过', '检测未在大多数衍生合同上实现的功能。', 'interface BaseInterface {<br/>&#160;&#160;&#160;&#160;function f1() external returns(uint);<br/>&#160;&#160;&#160;&#160;function f2() external returns(uint);<br/>}<br/>interface BaseInterface2 {<br/>&#160;&#160;&#160;&#160;function f3() external returns(uint);<br/>}<br/>contract DerivedContract is BaseInterface, BaseInterface2 {<br/>&#160;&#160;&#160;&#160;function f1() external returns(uint){<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;return 42;<br/>&#160;&#160;&#160;&#160;}<br/>}', 'DerivedContract不实现BaseInterface.f2或BaseInterface2.f3。 结果，合同将无法正确编译。 所有未实现的功能必须在要使用的合同上实现。', '在您打算直接使用的任何继承中实现所有未实现的功能（而不仅仅是继承）。'], [94, 'upgrade-050', '检查Solidity 0.5.x升级的代码', '提醒', 'exactly', '通过', '检查准备用于Solidity 0.5.0版本的代码更新。例如：参数个数不为1 的.call()、参数个数超过1个的 keccak256(...)等。', 'contract Token {<br/>&#160;&#160;&#160;&#160;uint totalSupply;<br/>&#160;&#160;&#160;&#160;function Token() {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;totalSupply = +1e18;<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function () payable {}<br/>}', '', '对这些更新的代码进行替换，准确地按照编译器支持的语法进行编写合约。'], [95, 'function-init-state', '检查非固定函数初始化的状态变量', '提醒', 'exactly', '通过', '检测非固定变量（函数中执行结果和函数中执行顺序相关）对状态变量进行初始化，状态变量初始化的不同顺序可能导致不同的初始化值。', 'contract StateVaribleInitFromDynamicFunction {<br/>&#160;&#160;&#160;&#160;uint public v_al = setval(); // Initialize from function (sets to 77)<br/>&#160;&#160;&#160;&#160;uint public w_al = 7;<br/>&#160;&#160;&#160;&#160;uint public x_al = setval(); // Initialize from function (sets to 88)<br/><br/>&#160;&#160;&#160;&#160;constructor(){<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function setval() public  returns(uint)  {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if(w_val == 0) {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;return 4;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;return 5;<br/>&#160;&#160;&#160;&#160;}<br/>}', 'v_al的值被初始化为4，x_al的值被初始化为5。然而调用者认为这两个值应该相同。因此，这将可能导致其他错误发生。', '检查通过非固定函数初始化状态变量的情况。如果这些变量必须初始化，可以在构造函数中进行初始化操作。'], [96, 'complex-function', '检查复杂的函数', '提醒', 'probably', '通过', '复杂的函数会消耗更多的gas，当gas大于设定的gas限制时，该交易会执行失败，所以每次调用都会失败。', 'contract Complex {<br/>&#160;&#160;&#160;&#160;function a() {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;int numberOfSides = 7;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;string shape;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;uint i0 = 0;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;uint i1 = 0;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;uint i2 = 0;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;uint i3 = 0;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;uint i4 = 0;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;uint i5 = 0;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;uint i6 = 0;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;uint i7 = 0;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;uint i8 = 0;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;uint i9 = 0;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;uint i10 = 0;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;...<br/>&#160;&#160;&#160;&#160;}<br/>}', 'Bob调用函数a（）将超过gas限制，永远调用不成功。', '如果可能，可以优化函数。'], [97, 'hardcoded', '检查地址的合法性', '提醒', 'probably', '通过', '合约包含未知地址，该地址可能用于某些恶意活动。需检查硬编码的地址及其用途。地址长容易出错，并且address的长度不够也不会报错，所以写错十分危险，这里做一个标识。', 'contract C {<br/>&#160;&#160;&#160;&#160;function f(uint a, uint b) pure returns (address) {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;address public multisig = 0xf64B584972FE6055a770477670208d737Fff282f;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;return multisig;<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '仔细核对地址是否有误，如有错误请抓紧时间修改。'], [98, 'overpowered-role', '检查权限是否过于集中', '提醒', 'probably', '通过', '此函数只能从一个地址调用，因此，系统在很大程度上依赖于这个地址。在这种情况下，可能会对投资者造成不良后果，例如，如果该地址的私钥受到损害，将导致该账户无法使用，进而导致合约无法正常运行。', 'contract Crowdsale {<br/>&#160;&#160;&#160;&#160;address public owner;<br/>&#160;&#160;&#160;&#160;uint rate;<br/>&#160;&#160;&#160;&#160;constructor() {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;owner = msg.sender;<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function setRate(_rate) public onlyOwner {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;rate = _rate;<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '仔细检查权力集中的地址，没有错误的话应确保其在合约运行期间可用。'], [99, 'reentrancy-limited-events', '检查重入漏洞导致事件乱序', '提醒', 'probably', '通过', '检测到重入错误，这里仅报告read、transfer受限制gas中可导致乱序事件的重入漏洞。', 'function bug(Called d){<br/>&#160;&#160;&#160;&#160;uint sendeth = 0;<br/>&#160;&#160;&#160;&#160;msg.sender.send(sendeth):<br/>&#160;&#160;&#160;&#160;emit Counter(counter);<br/>}', '如果重入“send”，则将以不正确的顺序显示“计数器”事件，这可能会导致第三方出现问题。', '应用check-effects-interactions模式。'], [100, 'reentrancy-limited-gas', '检查send和transfer导致的重入（有eth）', '提醒', 'probably', '通过', '在天然气价格变动的情况下，“send”和“transfer”并不能防止重入，只能说明重入比较困难。', 'function callme(){<br/>&#160;&#160;&#160;&#160;msg.sender.transfer(balances[msg.sender]):<br/>&#160;&#160;&#160;&#160;balances[msg.sender] = 0;<br/>}', '在天然气价格变动的情况下，“send”和“transfer”并不能防止重入。', '应用check-effects-interactions模式。'], [101, 'reentrancy-limited-gas-no-eth', '检查send和transfer导致的重入（无eth）', '提醒', 'probably', '通过', '相较于reentrancy-limited-gas，这里检测没有eth转移的send、transfer重入。', 'function callme(){<br/>&#160;&#160;&#160;&#160;uint sendeth = 0;<br/>&#160;&#160;&#160;&#160;msg.sender.transfer(sendeth):<br/>&#160;&#160;&#160;&#160;balances[msg.sender] = balances[msg.sender] - sendeth;<br/>}', '在天然气价格变动的情况下，“send”和“transfer”并不能防止重入。', '应用check-effects-interactions模式。'], [102, 'similar-names', '检测相似的变量', '提醒', 'probably', '通过', '检测名称过于相似的变量。', 'contract SimilarVariables {<br/>&#160;&#160;&#160;&#160;uint similarvariables1 = 1;<br/>&#160;&#160;&#160;&#160;uint similarvariables2 = 2;<br/>&#160;&#160;&#160;&#160;uint similarvariables3 = 3;<br/>}', '变量相似导致合约很难阅读。', '防止变量具有相似的名称。'], [103, 'too-many-digits', '检查是否有太多的数字符号', '提醒', 'probably', '通过', '具有许多数字的文字很难阅读和查看，变量名称容易误导人们。', 'contract MyContract{<br/>&#160;&#160;&#160;&#160;uint 1_ether = 10000000000000000000; <br/>}', '尽管1_ether看起来像1 ether，但它却是10 ether。 结果，很可能使用不正确。', '使用[Ether缩写] (https://solidity.readthedocs.io/en/latest/units-and-global-variables.html#ether-units), [Time缩写] (https://solidity.readthedocs.io/en/latest/units-and-global-variables.html#time-units), 或[科学计数法] (https://solidity.readthedocs.io/en/latest/types.html#rational-and-integer-literals)。'], [104, 'private-not-hidedata', '检查private可见性的使用', '提醒', 'possibly', '通过', '与常见的理解相反，private修饰符不会使变量不可见，矿工可以访问所有合约的代码和数据。开发人员必须解决以太坊缺乏隐私的问题。虽然是private，但是矿工是可以查看的。', 'contract OpenWallet {<br/>&#160;&#160;&#160;&#160;struct Wallet {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;bytes32 password;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;uint balance;<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;mapping(uint => Wallet) private wallets;<br/>&#160;&#160;&#160;&#160;function replacePassword(uint _wallet, bytes32 _previous, bytes32 _new) public {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;require(_previous == wallets[_wallet].password);<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;wallets[_wallet].password = _new;<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '仔细检查编写逻辑，确保编写的private变量是可以被看见的，否则应注意隐私，可以使用加密等手段。'], [105, 'safemath', '检查SafeMath的使用', '提醒', 'possibly', '通过', '使用了SafeMath库。使用SafeMath还是挺好的，但是如果对其进行修改，同样会造成一些漏洞。需要注意的是，我们呼吁使用safemath库，但是应该注意不要对其进行随意修改。', 'pragma solidity 0.4.24;<br/>import "../libraries/SafeMath.sol";<br/>contract SafeSubAndDiv {<br/>&#160;&#160;&#160;&#160;using SafeMath for uint256;<br/>&#160;&#160;&#160;&#160;function sub(uint a, uint b) public returns(uint) {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;return(a.sub(b));<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '仔细检查safemath库的相关函数，确保没有漏洞。'], [106, 'array-instead-bytes', '检查byte数组是否可被替换为bytes', '优化', 'exactly', '通过', 'byte[]可以转换为bytes以节约gas资源。', 'pragma solidity 0.4.24;<br/>contract C {<br/>&#160;&#160;&#160;&#160;byte[] someVariable;<br/>&#160;&#160;&#160;&#160;...<br/>}', '', '利用bytes替换byte[]可以节约gas。'], [107, 'boolean-equal', '检查与布尔常量的比较', '优化', 'exactly', '通过', '检测布尔常量的比较。不需要与true和false比较，这样多此一举（gas消耗）。', 'contract A {<br/>&#160;&#160;&#160;&#160;function f(bool x) public {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;// ...<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (x == true) { // bad!<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;   // ...<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;// ...<br/>&#160;&#160;&#160;&#160;}<br/>}', '布尔常量可以直接使用，而不必与true或false进行比较。', '删除等于布尔常量的等式。'], [108, 'code-no-effects', '检查无效代码', '优化', 'exactly', '通过', '在Solidity中，可以编写不会产生预期效果的代码。当前，solidity编译器将不会为无效代码返回警告。这可能导致引入无法正确执行预期动作的“死”代码。例如，容易遗漏括号中的括号msg.sender.call.value(address(this).balance)("");，这可能导致函数继续执行而无需将资金转入msg.sender。', "pragma solidity ^0.5.0;<br/>contract Wallet {<br/>&#160;&#160;&#160;&#160;mapping(address => uint) balance;<br/>&#160;&#160;&#160;&#160;// Withdraw funds from contract<br/>&#160;&#160;&#160;&#160;function withdraw(uint amount) public {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;require(amount <= balance[msg.sender], 'amount must be less than balance');<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;uint previousBalance = balance[msg.sender];<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;balance[msg.sender] = previousBalance - amount;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;// Attempt to send amount from the contract to msg.sender<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;msg.sender.call.value(amount);<br/>&#160;&#160;&#160;&#160;}<br/>}", '', '该代码为“死”代码，并不会执行成功，所以请修改或删除。'], [109, 'constable-states', '检查可以声明为常量的状态变量', '优化', 'exactly', '通过', '常量状态变量应声明为常量以节省气体。', 'contract B {<br/>&#160;&#160;&#160;&#160;address public mySistersAddress = 0x999999cf1046e68e36E1aA2E0E07105eDDD1f08E;<br/>&#160;&#160;&#160;&#160;function setUsed(uint a) public {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (msg.sender == MY_ADDRESS) {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;used = a;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;myFriendsAddress = 0xc0ffee254729296a45a3885639AC7E10F9d54980;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '将constant属性添加到永远不变的状态变量中。'], [110, 'event-before-revert', '检查event是否在revert前被调用', '优化', 'exactly', '通过', '事件在抛出异常前被调用，Revert回滚会使得事件白白花费gas。', 'contract Callbeforerevert {<br/>&#160;&#160;&#160;&#160;address owner;<br/>&#160;&#160;&#160;&#160;event EventName(address bidder, uint amount);<br/>&#160;&#160;&#160;&#160;function bad() public {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;emit EventName(msg.sender, msg.value); <br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;revert();<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '检查合约函数的逻辑结构，event事件会被回滚，所以没有必要，可以删除节约gas。'], [111, 'external-function', '检查可被声明为external的public函数', '优化', 'exactly', '通过', '具有public 可见性修饰符的函数，不在内部调用。将可见性级别更改为外部级别可以提高代码的可读性。此外，在许多情况下，与使用public可见性修饰符的函数相比，使用external可见性修饰符的函数花费的gas更少。', 'contract ContractWithFunctionCalledSuper {<br/>&#160;&#160;&#160;&#160;function callWithSuper() {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;uint256 i = 0;<br/>&#160;&#160;&#160;&#160;}<br/>}', 'callWithSuper()函数可以声明为external可见性。', '将“external”属性用于从未从合同内部调用的函数。'], [112, 'extra-gas-inloops', '检查额外的气体消耗', '优化', 'exactly', '通过', '在for循环或while循环的条件下使用非内存数组的状态变量.balance或.length。在这种情况下，循环的每次迭代都会消耗额外的gas。', 'contract NewContract {<br/>&#160;&#160;&#160;&#160;uint[] ss;<br/>&#160;&#160;&#160;&#160;function longLoop() {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;for(uint i = 0; i < ss.length; i++) {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;uint a = ss[i];<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* ... */<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '当.balance或.length不变的话，可用一个变量存储下来，然后再放到循环条件中可以节约gas。'], [113, 'missing-inheritance', '检测丢失的继承', '优化', 'exactly', '通过', '检测丢失的继承。', 'interface ISomething {<br/>&#160;&#160;&#160;&#160;function f1() external returns(uint);<br/>}<br/>contract Something {<br/>&#160;&#160;&#160;&#160;function f1() external returns(uint){<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;return 42;<br/>&#160;&#160;&#160;&#160;}<br/>}', '某些东西应该继承自ISomething。', '添加相应的继承。'], [114, 'redundant-statements', '检测无效语句使用的情况', '优化', 'exactly', '通过', '检测对无效语句的使用情况。', 'contract RedundantStatementsContract {<br/>&#160;&#160;&#160;&#160;constructor() public {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;uint; // Elementary Type Name<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;bool; // Elementary Type Name<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;RedundantStatementsContract; // Identifier<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function test() public returns (uint) {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;uint; // Elementary Type Name<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;assert; // Identifier<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;test; // Identifier<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;return 777;<br/>&#160;&#160;&#160;&#160;}<br/>}', '每条注释行都引用类型/标识符，但不对其执行任何操作，因此不会为此类语句生成代码，因此可以将其删除。', '如果多余的语句使代码拥塞但没有任何价值，请删除它们。'], [115, 'return-struct', '检查多个返回值的结构体替换', '优化', 'exactly', '通过', '考虑对内部或私有函数使用struct而不是多个返回值，它可以提高代码的可读性。函数传多个值使用struct。', 'pragma solidity 0.4.24;<br/>contract TestContract {<br/>&#160;&#160;&#160;&#160;function test() internal returns(uint a, address b, bool c, int d) {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;a = 1;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;b = msg.sender;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;c = true;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;d = 2;<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '将多个返回值保存到struct中再进行返回，可以提高代码的可读性。'], [116, 'revert-require', '检查if操作中Revert ', '优化', 'exactly', '通过', 'if (condition) { revert(); or throw;}可用require(condition)代替以节约资源gas。', 'contract Holder {<br/>&#160;&#160;&#160;&#160;uint public holdUntil;<br/>&#160;&#160;&#160;&#160;address public holder;<br/>&#160;&#160;&#160;&#160;function withdraw (uint a, uint b) external {<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (now < holdUntil){<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;revert();<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;holder.transfer(this.balance);<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '使用require(condition)代替构造if (condition) { revert(); or throw;}。'], [117, 'send-transfer', '检查Transfe替换Send', '优化', 'exactly', '通过', '执行检查以太币付款的建议方法是 addr.transfer(x)，如果transfer失败，则自动引发异常。', 'if(!addr.send(42 ether)) {<br/>&#160;&#160;&#160;&#160;revert();<br/>}', '', '使用transfer替换send会更加的安全。'], [118, 'unused-state', '检查未使用的状态变量', '优化', 'exactly', '通过', 'Solidity中允许使用未使用的变量，它们不会带来直接的安全问题。最好的做法是尽可能避免它们：导致计算量增加（以及不必要的气体消耗）表示错误或数据结构不正确，通常表示代码质量不佳导致代码噪音并降低代码的可读性。', 'contract A{<br/>&#160;&#160;&#160;&#160;address unused;<br/>&#160;&#160;&#160;&#160;address public unused2;<br/>&#160;&#160;&#160;&#160;address private unused3;<br/>&#160;&#160;&#160;&#160;address unused4;<br/>&#160;&#160;&#160;&#160;address used;<br/>&#160;&#160;&#160;&#160;function ceshi1 () external{<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;unused3 = address(0);<br/>&#160;&#160;&#160;&#160;}<br/>}', '', '删除未使用的状态变量。'], [119, 'costly-operations-loop', '循环中有昂贵的操作', '优化', 'probably', '通过', '循环内的昂贵操作。', 'contract CostlyOperationsInLoop{<br/>&#160;&#160;&#160;&#160;uint loop_count = 100;<br/>&#160;&#160;&#160;&#160;uint state_variable=0;<br/>&#160;&#160;&#160;&#160;function bad() external{<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;for (uint i=0; i < loop_count; i++){<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;state_variable++;<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;}<br/>&#160;&#160;&#160;&#160;function good() external{<br/>&#160;&#160;&#160;&#160;  uint local_variable = state_variable;<br/>&#160;&#160;&#160;&#160;  for (uint i=0; i < loop_count; i++){<br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;local_variable++;<br/>&#160;&#160;&#160;&#160;  }<br/>&#160;&#160;&#160;&#160;  state_variable = local_variable;<br/>&#160;&#160;&#160;&#160;}<br/>}', '由于昂贵的SSTOREs，循环中的增量状态变量会产生大量气体，这可能会导致气体不足。', '这个检测的是循环中是状态变量，状态变量比local变量会花费更多的gas，这个在之前是没有检测的，之前仅检测了length。']]

	def draw_pie(self, data=[], labels=[], use_colors=[]):
	    d = Drawing(500,230)
	    pie = Pie()
	    pie.x = 70 # x,y饼图在框中的坐标
	    pie.y = 5
	    pie.slices.label_boxStrokeColor = colors.white  #标签边框的颜色

	    pie.data = data      # 饼图上的数据
	    pie.labels = labels  # 数据的标签
	    pie.simpleLabels = 0 # 0 标签在标注线的右侧；1 在线上边
	    pie.sameRadii = 1    # 0 饼图是椭圆；1 饼图是圆形

	    pie.strokeWidth=0.5                         # 圆饼周围空白区域的宽度
	    pie.strokeColor= colors.white             # 整体饼图边界的颜色
	#     pie.slices.label_pointer_piePad = 10       # 圆饼和标签的距离
	#     pie.slices.label_pointer_edgePad = 25    # 标签和外边框的距离
	    pie.width = 180
	    pie.height = 180
	#     pie.direction = 'clockwise'
	    pie.pointerLabelMode  = 'LeftRight'
	#     print(dir(pie))
	    lg = Legend()
	    lg.x = 315
	    lg.y = 150
	    lg.dx = 20
	    lg.dy = 20
	    lg.deltax = 20
	    lg.deltay = 15
	    lg.dxTextSpace = 20
	    lg.columnMaximum = 6
	    lg.fontName = 'songti' #增加对中文字体的支持
	    lg.fontSize = 10.5
	    lg.colorNamePairs = list(zip(use_colors,labels))
	    lg.alignment = 'left'
	    lg.strokeColor = colors.white #legend边框颜色
	#     d.add(lab)
	    pie.slices.strokeColor = colors.white
	    pie.slices.strokeWidth = 0.5
	    for i in range(len(labels)):
	        pie.slices[i].fontName = 'songti' #设置中文
	        pie.slices[i].labelRadius = 0.6
	    for i, col in enumerate(use_colors):
	        pie.slices[i].fillColor  = col
	    lab = Label()
	    lab.x = 230  #x和y是文字的位置坐标
	    lab.y = 210
	    lab.setText('漏洞风险等级分布图')
	    lab.fontName = 'hei' #增加对中文字体的支持
	#     lab.boxFillColor=colors.HexColor(0x330066)
	#     print(dir(lab))
	    lab.fontSize = 15
	    d.add(lab)    
	    d.add(lg)
	    d.add(pie)
	    d.background = Rect(0,0,448,230,strokeWidth=1,strokeColor="#868686",fillColor=None) #边框颜色
	    return d

	# def __init__(self):
	# 	"""
		
	# 	"""
		

	def _output(self, result_maps, filename, time_start_para, auditcontent, report_path, contracts_names, auditid_para):
		global time_start, auditid
		time_start = time_start_para
		auditid = auditid_para

		story = []
		# 首页内容
		# story.append(Macro('canvas.saveState()'))
		# story.append(Macro("canvas.drawImage(r'report\研究报告封面-正面.jpg',0,0,"+str(A4[0])+","+str(A4[1])+")"))
		# story.append(Macro('canvas.setFillColorRGB(255,255,255)'))
		# story.append(Macro('canvas.setFont("hei", 20)'))
		# story.append(Macro("canvas.drawString(177, 396, '编号：07072016329851')"))
		# story.append(Macro("canvas.drawString(177, 346, '日期：2020-10-22')"))
		# story.append(Macro('canvas.restoreState()'))
		story.append(PageBreak())
		#剩余页time.strftime(’%Y{y}%m{m}%d{d}%H{h}%M{f}%S{s}’).format(y=‘年’, m=‘月’, d=‘日’, h=‘时’, f=‘分’, s=‘秒’)
		story.append(Paragraph("0x01 综述信息", self.title_style))
		story.append(Paragraph("智能分析（SmartAnalysis，简称SA）平台于"+time.strftime('%Y{y}%m{m}%d{d}', time_start).format(y='年', m='月', d='日')+"收到本智能合约安全审计申请并对合约进行了审计。", self.content_style))
		story.append(Paragraph("需要声明的是：SA仅就本报告出具前已经发生或存在的事实出具本报告，并就此承担相应责任。对于出具以后发生或存在的事实，SA无法判断其智能合约安全状况，亦不对此承担责任。本报告所作的安全审计分析及其他内容，仅基于信息提供者截至本报告出具时向慢雾提供的文件和资料（简称“已提供资料″）。SA假设：已提倛资料不存在缺失、被篡改、删减或隐瞒的情形。如已提倛资料信息缺失、被篡改、删减、隐瞒或反映的情况与实际情况不符的，SmartAnalysis对由此而导致的损失和不利影响不承担任何责任。", self.content_style))
		# 审计信息
		story.append(Spacer(1, 1.5 * mm))
		story.append(Paragraph("表1 合约审计信息", self.table_title_style))

		contracts_names_str = ""
		if len(contracts_names) > 3:
			contracts_names_str = contracts_names[0] + "," + contracts_names[1] + "," + contracts_names[2] + ",..."
		else:
			contracts_names_str = ','.join(contracts_names)

		task_data = [['项目','描述'],['合约名称',contracts_names_str],['合约类型','以太坊合约'],['代码语言','Solidity'],['合约文件',filename.split('/')[-1]],['合约地址',''],['审计人员','智能分析团队'],['审计时间',time.strftime("%Y-%m-%d %H:%M:%S", time_start)],['审计工具','智能分析（SA）']]
		task_table = Table(task_data, colWidths=[83 * mm, 83 * mm], rowHeights=9 * mm, style=self.common_style)
		story.append(task_table)
		story.append(Spacer(1, 2 * mm))
		story.append(Paragraph("表1详细的展示了本次合约审计的相关信息，下面将详细介绍合约安全审计的细节及结果。", self.content_style))

		story.append(Paragraph("0x02 合约审计结果", self.title_style))
		story.append(Paragraph("2.1 漏洞分布", self.sub_title_style))
		story.append(Paragraph("本次安全审计漏洞风险按危险等级分布：", self.content_style))
		story.append(Paragraph("表2 合约审计漏洞分布概览", self.table_title_style))

		loophole_distribute = {'High':0,'Medium':0,'Low':0,'Informational':0,'Optimization':0}
		result_number_color = {}
		for i in range(1,len(self.table_result)):
		    if self.table_result[i][1] in result_maps.keys():
		        loophole_distribute_val = {'High':0,'Medium':0,'Low':0,'Informational':0,'Optimization':0}
		        for v in result_maps[self.table_result[i][1]]:
		            loophole_distribute_val[v['impact']] = loophole_distribute_val[v['impact']] + 1
		        numberimpact = ""
		        numberimpact_nocolor = ""
		        if loophole_distribute_val['High'] != 0:
		            loophole_distribute['High'] = loophole_distribute['High'] + loophole_distribute_val['High']
		            if numberimpact == '':
		                numberimpact = '<font color="#E61A1A">高危:' + str(loophole_distribute_val['High']) + '</font>'
		                numberimpact_nocolor = '高危:' + str(loophole_distribute_val['High'])
		            else:
		                numberimpact = numberimpact + '\\<font color="#E61A1A ">高危:' + str(loophole_distribute_val['High']) + '</font>'
		                numberimpact_nocolor = numberimpact_nocolor + '\\高危:' + str(loophole_distribute_val['High'])
		        if loophole_distribute_val['Medium'] != 0:
		            loophole_distribute['Medium'] = loophole_distribute['Medium'] + loophole_distribute_val['Medium']
		            if numberimpact == '':
		                numberimpact = '<font color="#FF6600">中危:' + str(loophole_distribute_val['Medium']) + '</font>'
		                numberimpact_nocolor = '中危:' + str(loophole_distribute_val['Medium'])
		            else:
		                numberimpact = numberimpact + '\\<font color="#FF6600">中危:' + str(loophole_distribute_val['Medium']) + '</font>'
		                numberimpact_nocolor = numberimpact_nocolor + '\\中危:' + str(loophole_distribute_val['Medium'])
		        if loophole_distribute_val['Low'] != 0:
		            loophole_distribute['Low'] = loophole_distribute['Low'] + loophole_distribute_val['Low']
		            if numberimpact == '':
		                numberimpact = '<font color="#DDB822">低危:' + str(loophole_distribute_val['Low']) + '</font>'
		                numberimpact_nocolor = '低危:' + str(loophole_distribute_val['Low'])
		            else:
		                numberimpact = numberimpact + '\\<font color="#DDB822">低危:' + str(loophole_distribute_val['Low']) + '</font>'
		                numberimpact_nocolor = numberimpact_nocolor + '\\低危:' + str(loophole_distribute_val['Low'])
		        if loophole_distribute_val['Informational'] != 0:
		            loophole_distribute['Informational'] = loophole_distribute['Informational'] + loophole_distribute_val['Informational']
		            if numberimpact == '':
		                numberimpact = '<font color="#ff66ff">提醒:' + str(loophole_distribute_val['Informational']) + '</font>'
		                numberimpact_nocolor = '提醒:' + str(loophole_distribute_val['Informational'])
		            else:
		                numberimpact = numberimpact + '\\<font color="#ff66ff">提醒:' + str(loophole_distribute_val['Informational']) + '</font>'
		                numberimpact_nocolor = numberimpact_nocolor + '\\提醒:' + str(loophole_distribute_val['Informational'])
		        if loophole_distribute_val['Optimization'] != 0:
		            loophole_distribute['Optimization'] = loophole_distribute['Optimization'] + loophole_distribute_val['Optimization']
		            if numberimpact == '':
		                numberimpact = '<font color="#22DDDD">优化:' + str(loophole_distribute_val['Optimization']) + '</font>'
		                numberimpact_nocolor = '优化:' + str(loophole_distribute_val['Optimization'])
		            else:
		                numberimpact = numberimpact + '\\<font color="#22DDDD">优化:' + str(loophole_distribute_val['Optimization']) + '</font>'
		                numberimpact_nocolor = numberimpact_nocolor + '\\优化:' + str(loophole_distribute_val['Optimization'])
		        self.table_result[i][5] = numberimpact_nocolor
		        result_number_color[self.table_result[i][1]] = numberimpact

		task_data_1 = [['漏洞风险等级分布'],['高危','中危','低危','提醒','优化'],[loophole_distribute['High'],loophole_distribute['Medium'],loophole_distribute['Low'],loophole_distribute['Informational'],loophole_distribute['Optimization']]]
		task_table_1 = Table(task_data_1, colWidths=[30 * mm, 30 * mm, 30 * mm, 30 * mm, 30 * mm], rowHeights=9 * mm, style=self.common_style_1)
		story.append(task_table_1)
		pie_data = task_data_1[2]
		pie_labs = task_data_1[1]
		pie_color = [colors.HexColor('#E61A1A'),colors.HexColor('#FF6600'),colors.HexColor('#DDB822'),colors.HexColor('#ff66ff'),colors.HexColor('#22DDDD')]
		task_pie = self.draw_pie(pie_data,pie_labs,pie_color)
		story.append(task_pie)
		story.append(Paragraph("图1 漏洞风险等级分布图", self.graph_title_style))
		story.append(Paragraph("本次安全审计高危漏洞"+str(loophole_distribute['High'])+"个，中危"+str(loophole_distribute['Medium'])+"个，低危"+str(loophole_distribute['Low'])+"个，优化"+str(loophole_distribute['Optimization'])+"个，需要提醒的地方"+str(loophole_distribute['Informational'])+"个。", self.content_daoyin_style_red))
		story.append(Paragraph("2.2 审计结果", self.sub_title_style))
		story.append(Paragraph("本次安全审计测试项94项，测试项如下（其他未知安全漏洞不包含在本次审计责任范围）：", self.content_style))
		# common_style_result_all_type
		for i in range(1,len(self.table_result)):
		    if '高危' in self.table_result[i][3]:
		        self.common_style_result_all_type.append(('TEXTCOLOR', (3, i), (3, i), colors.HexColor('#E61A1A')))
		        if '通过' in self.table_result[i][5]:
		            self.common_style_result_all_type.append(('TEXTCOLOR', (5, i), (5, i), colors.HexColor('#2BD591')))
		        else:
		            self.common_style_result_all_type.append(('TEXTCOLOR', (5, i), (5, i), colors.HexColor('#E61A1A')))
		    elif '中危' in self.table_result[i][3]:
		        self.common_style_result_all_type.append(('TEXTCOLOR', (3, i), (3, i), colors.HexColor('#FF6600')))
		        if '通过' in self.table_result[i][5]:
		            self.common_style_result_all_type.append(('TEXTCOLOR', (5, i), (5, i), colors.HexColor('#2BD591')))
		        else:
		            self.common_style_result_all_type.append(('TEXTCOLOR', (5, i), (5, i), colors.HexColor('#FF6600')))
		    elif '低危' in self.table_result[i][3]:
		        self.common_style_result_all_type.append(('TEXTCOLOR', (3, i), (3, i), colors.HexColor('#DDB822')))
		        if '通过' in self.table_result[i][5]:
		            self.common_style_result_all_type.append(('TEXTCOLOR', (5, i), (5, i), colors.HexColor('#2BD591')))
		        else:
		            self.common_style_result_all_type.append(('TEXTCOLOR', (5, i), (5, i), colors.HexColor('#DDB822')))
		    elif '提醒' in self.table_result[i][3]:
		        self.common_style_result_all_type.append(('TEXTCOLOR', (3, i), (3, i), colors.HexColor('#ff66ff')))
		        if '通过' in self.table_result[i][5]:
		            self.common_style_result_all_type.append(('TEXTCOLOR', (5, i), (5, i), colors.HexColor('#2BD591')))
		        else:
		            self.common_style_result_all_type.append(('TEXTCOLOR', (5, i), (5, i), colors.HexColor('#ff66ff')))
		    elif '优化' in self.table_result[i][3]:
		        self.common_style_result_all_type.append(('TEXTCOLOR', (3, i), (3, i), colors.HexColor('#22DDDD')))
		        if '通过' in self.table_result[i][5]:
		            self.common_style_result_all_type.append(('TEXTCOLOR', (5, i), (5, i), colors.HexColor('#2BD591')))
		        else:
		            self.common_style_result_all_type.append(('TEXTCOLOR', (5, i), (5, i), colors.HexColor('#22DDDD')))
		    if i%2==1:
		        self.common_style_result_all_type.append(('BACKGROUND', (0, i), (-1, i), colors.HexColor('#d9e2f3')))
		common_style_result_all = TableStyle(self.common_style_result_all_type)
		story.append(Paragraph("表3 合约审计项目", self.table_title_style))
		task_table_2 = Table([var[0:6] for var in self.table_result], colWidths=[10 * mm, 50 * mm, 60 * mm, 18 * mm, 19 * mm, 22 * mm], rowHeights=7.5 * mm, style=common_style_result_all)
		story.append(task_table_2)

		story.append(Paragraph("0x03 合约代码", self.title_style))
		story.append(Paragraph("3.1 代码及标注", self.sub_title_style))
		story.append(Paragraph("在每一个合约代码中相应位置，都已通过注释的形式标注出安全漏洞以及编码规范问题，注释标志以//StFt 开始，具体详见下述合约代码内容。", self.content_style))
		story.append(Paragraph(auditcontent, self.code_style))

		story.append(Paragraph("0x04 合约审计详情", self.title_style))
		for i in range(1,len(self.table_result)):
		    story.append(Paragraph('<font style="font-weight:bold">4.'+str(i)+' '+self.table_result[i][1]+'</font>', self.sub_title_style_romanbold))
		    if '通过' in self.table_result[i][5]:
		        #通过的
		        story.append(Paragraph("漏洞描述", self.sub_sub_title_style))
		        story.append(Paragraph(self.table_result[i][6], self.content_style))
		        story.append(Paragraph("适用场景", self.sub_sub_title_style))
		        story.append(Paragraph(self.table_result[i][7], self.code_style))
		        if self.table_result[i][8]:
		            story.append(Paragraph(self.table_result[i][8], self.content_style_codeadd))
		        story.append(Paragraph('审计结果：<font color="#2BD591">【通过】</font>', self.sub_sub_title_style))
		        story.append(Paragraph('安全建议：无', self.sub_sub_title_style))
		    else:
		        #有漏洞的
		        story.append(Paragraph("漏洞描述", self.sub_sub_title_style))
		        story.append(Paragraph(self.table_result[i][6], self.content_style))
		        story.append(Paragraph('审计结果：【'+result_number_color[self.table_result[i][1]]+'】', self.sub_sub_title_style))
		        story.append(Paragraph("针对此项目，合约中存在具体的问题如下：", self.content_style))
		        for v in result_maps[self.table_result[i][1]]:
		            if v['impact'] == 'High':
		                description_vals = v['description'].replace("\t","&#160;&#160;&#160;&#160;").split('\n')
		                story.append(Paragraph('<font color="#E61A1A" face="songti">(高危)</font>'+description_vals[0], self.content_style_roman))
		                for j in range(1,len(description_vals)):
		                    story.append(Paragraph(description_vals[j], self.content_style_roman))
		            elif v['impact'] == 'Medium':
		                description_vals = v['description'].replace("\t","&#160;&#160;&#160;&#160;").split('\n')
		                story.append(Paragraph('<font color="#FF6600" face="songti">(中危)</font>'+description_vals[0], self.content_style_roman))
		                for j in range(1,len(description_vals)):
		                    story.append(Paragraph(description_vals[j], self.content_style_roman))
		            elif v['impact'] == 'Low':
		                description_vals = v['description'].replace("\t","&#160;&#160;&#160;&#160;").split('\n')
		                story.append(Paragraph('<font color="#DDB822" face="songti">(低危)</font>'+description_vals[0], self.content_style_roman))
		                for j in range(1,len(description_vals)):
		                    story.append(Paragraph(description_vals[j], self.content_style_roman))
		            elif v['impact'] == 'Informational':
		                description_vals = v['description'].replace("\t","&#160;&#160;&#160;&#160;").split('\n')
		                story.append(Paragraph('<font color="#ff66ff" face="songti">(提醒)</font>'+description_vals[0], self.content_style_roman))
		                for j in range(1,len(description_vals)):
		                    story.append(Paragraph(description_vals[j], self.content_style_roman))              
		            elif v['impact'] == 'Optimization':
		                description_vals = v['description'].replace("\t","&#160;&#160;&#160;&#160;").split('\n')
		                story.append(Paragraph('<font color="#22DDDD" face="songti">(优化)</font>'+description_vals[0], self.content_style_roman))
		                for j in range(1,len(description_vals)):
		                    story.append(Paragraph(description_vals[j], self.content_style_roman))
		        story.append(Paragraph('安全建议', self.sub_sub_title_style))
		        story.append(Paragraph(self.table_result[i][9], self.content_style))
		# story.append(c)
		story.append(PageBreak())
		#尾页
		story.append(Spacer(0, 20 * mm))
		# story.append(Macro('canvas.saveState()'))
		# story.append(Macro("canvas.drawImage(r'report\研究报告封面-背面.jpg',0,0,"+str(A4[0])+","+str(A4[1])+")"))
		# story.append(Macro('canvas.restoreState()'))
		doc = SimpleDocTemplate(report_path,
		                        pagesize=A4,
		                        leftMargin=20 * mm, rightMargin=20 * mm, topMargin=27 * mm, bottomMargin=25 * mm)
		doc.build(story,canvasmaker=NumberedCanvasChinese)
		print("The audit report has been saved to "+report_path+".")
	
	#output the main audit result
	def _output_main(self, result_maps, filename, time_start_para, auditcontent, report_path, contracts_names, auditid_para):
		global time_start, auditid
		time_start = time_start_para
		auditid = auditid_para

		story = []
		# 首页内容
		# story.append(Macro('canvas.saveState()'))
		# story.append(Macro("canvas.drawImage(r'report\研究报告封面-正面.jpg',0,0,"+str(A4[0])+","+str(A4[1])+")"))
		# story.append(Macro('canvas.setFillColorRGB(255,255,255)'))
		# story.append(Macro('canvas.setFont("hei", 20)'))
		# story.append(Macro("canvas.drawString(177, 396, '编号：07072016329851')"))
		# story.append(Macro("canvas.drawString(177, 346, '日期：2020-10-22')"))
		# story.append(Macro('canvas.restoreState()'))
		story.append(PageBreak())
		#剩余页time.strftime(’%Y{y}%m{m}%d{d}%H{h}%M{f}%S{s}’).format(y=‘年’, m=‘月’, d=‘日’, h=‘时’, f=‘分’, s=‘秒’)
		story.append(Paragraph("0x01 综述信息", self.title_style))
		story.append(Paragraph("智能分析（SmartAnalysis，简称SA）平台于"+time.strftime('%Y{y}%m{m}%d{d}', time_start).format(y='年', m='月', d='日')+"收到本智能合约安全审计申请并对合约进行了审计。", self.content_style))
		story.append(Paragraph("需要声明的是：SA仅就本报告出具前已经发生或存在的事实出具本报告，并就此承担相应责任。对于出具以后发生或存在的事实，SA无法判断其智能合约安全状况，亦不对此承担责任。本报告所作的安全审计分析及其他内容，仅基于信息提供者截至本报告出具时向慢雾提供的文件和资料（简称“已提供资料″）。SA假设：已提倛资料不存在缺失、被篡改、删减或隐瞒的情形。如已提倛资料信息缺失、被篡改、删减、隐瞒或反映的情况与实际情况不符的，SmartAnalysis对由此而导致的损失和不利影响不承担任何责任。", self.content_style))
		# 审计信息
		story.append(Spacer(1, 1.5 * mm))
		story.append(Paragraph("表1 合约审计信息", self.table_title_style))
		contracts_names_str = ""
		if len(contracts_names) > 3:
			contracts_names_str = contracts_names[0] + "," + contracts_names[1] + "," + contracts_names[2] + ",..."
		else:
			contracts_names_str = ','.join(contracts_names)
		task_data = [['项目','描述'],['合约名称', contracts_names_str],['合约类型','以太坊合约'],['代码语言','Solidity'],['合约文件',filename.split('/')[-1]],['合约地址',''],['审计人员','智能分析团队'],['审计时间',time.strftime("%Y-%m-%d %H:%M:%S", time_start)],['审计工具','智能分析（SA）']]
		task_table = Table(task_data, colWidths=[83 * mm, 83 * mm], rowHeights=9 * mm, style=self.common_style)
		story.append(task_table)
		story.append(Spacer(1, 2 * mm))
		story.append(Paragraph("表1详细的展示了本次合约审计的相关信息，下面将详细介绍合约安全审计的细节及结果。", self.content_style))

		story.append(Paragraph("0x02 合约审计结果", self.title_style))
		story.append(Paragraph("2.1 漏洞分布", self.sub_title_style))
		story.append(Paragraph("本次安全审计漏洞风险按危险等级分布：", self.content_style))
		story.append(Paragraph("表2 合约审计漏洞分布概览", self.table_title_style))

		loophole_distribute = {'High':0,'Medium':0,'Low':0,'Informational':0,'Optimization':0}
		result_number_color = {}
		for i in range(1,len(self.table_result)):
		    if self.table_result[i][1] in result_maps.keys():
		        loophole_distribute_val = {'High':0,'Medium':0,'Low':0,'Informational':0,'Optimization':0}
		        for v in result_maps[self.table_result[i][1]]:
		            loophole_distribute_val[v['impact']] = loophole_distribute_val[v['impact']] + 1
		        numberimpact = ""
		        numberimpact_nocolor = ""
		        if loophole_distribute_val['High'] != 0:
		            loophole_distribute['High'] = loophole_distribute['High'] + loophole_distribute_val['High']
		            if numberimpact == '':
		                numberimpact = '<font color="#E61A1A">高危:' + str(loophole_distribute_val['High']) + '</font>'
		                numberimpact_nocolor = '高危:' + str(loophole_distribute_val['High'])
		            else:
		                numberimpact = numberimpact + '\\<font color="#E61A1A ">高危:' + str(loophole_distribute_val['High']) + '</font>'
		                numberimpact_nocolor = numberimpact_nocolor + '\\高危:' + str(loophole_distribute_val['High'])
		        if loophole_distribute_val['Medium'] != 0:
		            loophole_distribute['Medium'] = loophole_distribute['Medium'] + loophole_distribute_val['Medium']
		            if numberimpact == '':
		                numberimpact = '<font color="#FF6600">中危:' + str(loophole_distribute_val['Medium']) + '</font>'
		                numberimpact_nocolor = '中危:' + str(loophole_distribute_val['Medium'])
		            else:
		                numberimpact = numberimpact + '\\<font color="#FF6600">中危:' + str(loophole_distribute_val['Medium']) + '</font>'
		                numberimpact_nocolor = numberimpact_nocolor + '\\中危:' + str(loophole_distribute_val['Medium'])
		        if loophole_distribute_val['Low'] != 0:
		            loophole_distribute['Low'] = loophole_distribute['Low'] + loophole_distribute_val['Low']
		            if numberimpact == '':
		                numberimpact = '<font color="#DDB822">低危:' + str(loophole_distribute_val['Low']) + '</font>'
		                numberimpact_nocolor = '低危:' + str(loophole_distribute_val['Low'])
		            else:
		                numberimpact = numberimpact + '\\<font color="#DDB822">低危:' + str(loophole_distribute_val['Low']) + '</font>'
		                numberimpact_nocolor = numberimpact_nocolor + '\\低危:' + str(loophole_distribute_val['Low'])
		        if loophole_distribute_val['Informational'] != 0:
		            loophole_distribute['Informational'] = loophole_distribute['Informational'] + loophole_distribute_val['Informational']
		            if numberimpact == '':
		                numberimpact = '<font color="#ff66ff">提醒:' + str(loophole_distribute_val['Informational']) + '</font>'
		                numberimpact_nocolor = '提醒:' + str(loophole_distribute_val['Informational'])
		            else:
		                numberimpact = numberimpact + '\\<font color="#ff66ff">提醒:' + str(loophole_distribute_val['Informational']) + '</font>'
		                numberimpact_nocolor = numberimpact_nocolor + '\\提醒:' + str(loophole_distribute_val['Informational'])
		        if loophole_distribute_val['Optimization'] != 0:
		            loophole_distribute['Optimization'] = loophole_distribute['Optimization'] + loophole_distribute_val['Optimization']
		            if numberimpact == '':
		                numberimpact = '<font color="#22DDDD">优化:' + str(loophole_distribute_val['Optimization']) + '</font>'
		                numberimpact_nocolor = '优化:' + str(loophole_distribute_val['Optimization'])
		            else:
		                numberimpact = numberimpact + '\\<font color="#22DDDD">优化:' + str(loophole_distribute_val['Optimization']) + '</font>'
		                numberimpact_nocolor = numberimpact_nocolor + '\\优化:' + str(loophole_distribute_val['Optimization'])
		        self.table_result[i][5] = numberimpact_nocolor
		        result_number_color[self.table_result[i][1]] = numberimpact

		task_data_1 = [['漏洞风险等级分布'],['高危','中危','低危','提醒','优化'],[loophole_distribute['High'],loophole_distribute['Medium'],loophole_distribute['Low'],loophole_distribute['Informational'],loophole_distribute['Optimization']]]
		task_table_1 = Table(task_data_1, colWidths=[30 * mm, 30 * mm, 30 * mm, 30 * mm, 30 * mm], rowHeights=9 * mm, style=self.common_style_1)
		story.append(task_table_1)
		pie_data = task_data_1[2]
		pie_labs = task_data_1[1]
		pie_color = [colors.HexColor('#E61A1A'),colors.HexColor('#FF6600'),colors.HexColor('#DDB822'),colors.HexColor('#ff66ff'),colors.HexColor('#22DDDD')]
		task_pie = self.draw_pie(pie_data,pie_labs,pie_color)
		story.append(task_pie)
		story.append(Paragraph("图1 漏洞风险等级分布图", self.graph_title_style))
		story.append(Paragraph("本次安全审计高危漏洞"+str(loophole_distribute['High'])+"个，中危"+str(loophole_distribute['Medium'])+"个，低危"+str(loophole_distribute['Low'])+"个，优化"+str(loophole_distribute['Optimization'])+"个，需要提醒的地方"+str(loophole_distribute['Informational'])+"个。", self.content_daoyin_style_red))
		story.append(Paragraph("2.2 审计结果", self.sub_title_style))
		story.append(Paragraph("本次安全审计测试项94项，测试项如下（其他未知安全漏洞不包含在本次审计责任范围）：", self.content_style))
		# common_style_result_all_type
		for i in range(1,len(self.table_result)):
		    if '高危' in self.table_result[i][3]:
		        self.common_style_result_all_type.append(('TEXTCOLOR', (3, i), (3, i), colors.HexColor('#E61A1A')))
		        if '通过' in self.table_result[i][5]:
		            self.common_style_result_all_type.append(('TEXTCOLOR', (5, i), (5, i), colors.HexColor('#2BD591')))
		        else:
		            self.common_style_result_all_type.append(('TEXTCOLOR', (5, i), (5, i), colors.HexColor('#E61A1A')))
		    elif '中危' in self.table_result[i][3]:
		        self.common_style_result_all_type.append(('TEXTCOLOR', (3, i), (3, i), colors.HexColor('#FF6600')))
		        if '通过' in self.table_result[i][5]:
		            self.common_style_result_all_type.append(('TEXTCOLOR', (5, i), (5, i), colors.HexColor('#2BD591')))
		        else:
		            self.common_style_result_all_type.append(('TEXTCOLOR', (5, i), (5, i), colors.HexColor('#FF6600')))
		    elif '低危' in self.table_result[i][3]:
		        self.common_style_result_all_type.append(('TEXTCOLOR', (3, i), (3, i), colors.HexColor('#DDB822')))
		        if '通过' in self.table_result[i][5]:
		            self.common_style_result_all_type.append(('TEXTCOLOR', (5, i), (5, i), colors.HexColor('#2BD591')))
		        else:
		            self.common_style_result_all_type.append(('TEXTCOLOR', (5, i), (5, i), colors.HexColor('#DDB822')))
		    elif '提醒' in self.table_result[i][3]:
		        self.common_style_result_all_type.append(('TEXTCOLOR', (3, i), (3, i), colors.HexColor('#ff66ff')))
		        if '通过' in self.table_result[i][5]:
		            self.common_style_result_all_type.append(('TEXTCOLOR', (5, i), (5, i), colors.HexColor('#2BD591')))
		        else:
		            self.common_style_result_all_type.append(('TEXTCOLOR', (5, i), (5, i), colors.HexColor('#ff66ff')))
		    elif '优化' in self.table_result[i][3]:
		        self.common_style_result_all_type.append(('TEXTCOLOR', (3, i), (3, i), colors.HexColor('#22DDDD')))
		        if '通过' in self.table_result[i][5]:
		            self.common_style_result_all_type.append(('TEXTCOLOR', (5, i), (5, i), colors.HexColor('#2BD591')))
		        else:
		            self.common_style_result_all_type.append(('TEXTCOLOR', (5, i), (5, i), colors.HexColor('#22DDDD')))
		    if i%2==1:
		        self.common_style_result_all_type.append(('BACKGROUND', (0, i), (-1, i), colors.HexColor('#d9e2f3')))
		common_style_result_all = TableStyle(self.common_style_result_all_type)
		story.append(Paragraph("表3 合约审计项目", self.table_title_style))
		task_table_2 = Table([var[0:6] for var in self.table_result], colWidths=[10 * mm, 50 * mm, 60 * mm, 18 * mm, 19 * mm, 22 * mm], rowHeights=7.5 * mm, style=common_style_result_all)
		story.append(task_table_2)

		story.append(Paragraph("0x03 合约代码", self.title_style))
		story.append(Paragraph("3.1 代码及标注", self.sub_title_style))
		story.append(Paragraph("在每一个合约代码中相应位置，都已通过注释的形式标注出安全漏洞以及编码规范问题，注释标志以//StFt 开始，具体详见下述合约代码内容。", self.content_style))
		story.append(Paragraph(auditcontent, self.code_style))

		story.append(Paragraph("0x04 合约审计详情", self.title_style))
		num = 1
		for i in range(1,len(self.table_result)):
		    if '通过' not in self.table_result[i][5]:
		        #有漏洞的
		       	story.append(Paragraph('<font style="font-weight:bold">4.'+str(num)+' '+self.table_result[i][1]+'</font>', self.sub_title_style_romanbold))
		        story.append(Paragraph("漏洞描述", self.sub_sub_title_style))
		        story.append(Paragraph(self.table_result[i][6], self.content_style))
		        story.append(Paragraph('审计结果：【'+result_number_color[self.table_result[i][1]]+'】', self.sub_sub_title_style))
		        story.append(Paragraph("针对此项目，合约中存在具体的问题如下：", self.content_style))
		        for v in result_maps[self.table_result[i][1]]:
		            if v['impact'] == 'High':
		                description_vals = v['description'].replace("\t","&#160;&#160;&#160;&#160;").split('\n')
		                story.append(Paragraph('<font color="#E61A1A" face="songti">(高危)</font>'+description_vals[0], self.content_style_roman))
		                for j in range(1,len(description_vals)):
		                    story.append(Paragraph(description_vals[j], self.content_style_roman))
		            elif v['impact'] == 'Medium':
		                description_vals = v['description'].replace("\t","&#160;&#160;&#160;&#160;").split('\n')
		                story.append(Paragraph('<font color="#FF6600" face="songti">(中危)</font>'+description_vals[0], self.content_style_roman))
		                for j in range(1,len(description_vals)):
		                    story.append(Paragraph(description_vals[j], self.content_style_roman))
		            elif v['impact'] == 'Low':
		                description_vals = v['description'].replace("\t","&#160;&#160;&#160;&#160;").split('\n')
		                story.append(Paragraph('<font color="#DDB822" face="songti">(低危)</font>'+description_vals[0], self.content_style_roman))
		                for j in range(1,len(description_vals)):
		                    story.append(Paragraph(description_vals[j], self.content_style_roman))
		            elif v['impact'] == 'Informational':
		                description_vals = v['description'].replace("\t","&#160;&#160;&#160;&#160;").split('\n')
		                story.append(Paragraph('<font color="#ff66ff" face="songti">(提醒)</font>'+description_vals[0], self.content_style_roman))
		                for j in range(1,len(description_vals)):
		                    story.append(Paragraph(description_vals[j], self.content_style_roman))              
		            elif v['impact'] == 'Optimization':
		                description_vals = v['description'].replace("\t","&#160;&#160;&#160;&#160;").split('\n')
		                story.append(Paragraph('<font color="#22DDDD" face="songti">(优化)</font>'+description_vals[0], self.content_style_roman))
		                for j in range(1,len(description_vals)):
		                    story.append(Paragraph(description_vals[j], self.content_style_roman))
		        story.append(Paragraph('安全建议', self.sub_sub_title_style))
		        story.append(Paragraph(self.table_result[i][9], self.content_style))
		        num = num + 1
		# story.append(c)
		story.append(PageBreak())
		#尾页
		story.append(Spacer(0, 20 * mm))
		# story.append(Macro('canvas.saveState()'))
		# story.append(Macro("canvas.drawImage(r'report\研究报告封面-背面.jpg',0,0,"+str(A4[0])+","+str(A4[1])+")"))
		# story.append(Macro('canvas.restoreState()'))
		doc = SimpleDocTemplate(report_path,
		                        pagesize=A4,
		                        leftMargin=20 * mm, rightMargin=20 * mm, topMargin=27 * mm, bottomMargin=25 * mm)
		doc.build(story,canvasmaker=NumberedCanvasChinese)
		print("The audit report has been saved to "+report_path+".")
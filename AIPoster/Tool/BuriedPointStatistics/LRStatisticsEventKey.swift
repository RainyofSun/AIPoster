//
//  LRStatisticsEventKey.swift
//  HSTranslation
//
//  Created by 苍蓝猛兽 on 2022/9/29.
//

// MARK: 统计事件Key
struct StatisticsEvent {
    /// 统计Key
    var key: String
    /// 统计注释
    var note: String
}

// MARK: 首页统计事件
/// 源语言输入的计数统计
let homeSourceLangInpputKey: StatisticsEvent          = StatisticsEvent.init(key: "homeSourceLangageInput", note: "源语言输入的计数统计")
/// 目标语言的输入计数统计
let homeTargetLangInputKey: StatisticsEvent           = StatisticsEvent.init(key: "homeTargetLanguageInput", note: "目标语言的输入计数统计")
/// 源语言与目标语言的交换计数统计
let homeTranslateSwitchKey: StatisticsEvent           = StatisticsEvent.init(key: "homeSourceAndTargetSwitch", note: "源语言与目标语言的交换计数统计")
/// 从粘贴板复制过来的内容计数统计
let homeCopyFromPasteboardKey: StatisticsEvent        = StatisticsEvent.init(key: "homeCopyTextFromPasteboard", note: "从粘贴板复制过来的内容计数统计")
/// 首页翻译结果的分享的计数统计
let homeShareResultOfTranslateKey: StatisticsEvent    = StatisticsEvent.init(key: "homeShare", note: "首页翻译结果的分享的计数统计")
/// 首页翻译结果的收藏的计数统计
let homeCollectResultOfTranslateKey: StatisticsEvent  = StatisticsEvent.init(key: "homeCollected", note: "首页翻译结果的收藏的计数统计")
/// 首页翻译结果的点赞的计数统计
let homeLikeTranslateResultKey: StatisticsEvent       = StatisticsEvent.init(key: "homeLikeTranslateResult", note: "首页翻译结果的点赞的计数统计")
/// 首页翻译结果的差评的计数统计
let homeDislikeTanslateResultKey: StatisticsEvent     = StatisticsEvent.init(key: "homeDislikeTanslateResult", note: "首页翻译结果的差评的计数统计")
/// 首页选择源语言按钮点击计数统计
let homeSwitchSourceLangKey: StatisticsEvent          = StatisticsEvent.init(key: "homeSwitchSourceLanguage", note: "首页选择源语言按钮点击计数统计")
/// 首页选择目标语言按钮点击计数统计
let homeSwitchTargetLangKey: StatisticsEvent          = StatisticsEvent.init(key: "homeSwitchTargetLanguage", note: "首页选择目标语言按钮点击计数统计")
/// 翻译结果的同义词等多个内容的计数统计
let homeShowMoreTranslateResultsKey: StatisticsEvent  = StatisticsEvent.init(key: "homeShowAlternativeResults", note: "翻译结果的同义词等多个内容的计数统计")
/// 翻译完成后检查选择的源语言与输入内容语言类型的不匹配按钮展示计数统计
let homeShowErrorCorrectionKey: StatisticsEvent       = StatisticsEvent.init(key: "homeShowErrorCorrection", note: "翻译完成后检查选择的源语言与输入内容语言类型的不匹配按钮展示计数统计")
/// 翻译完成后检查选择的源语言与输入内容语言类型的不匹配按钮点击计数统计
let homeTouchErrorCorrectionKey: StatisticsEvent      = StatisticsEvent.init(key: "homeTouchErrorCorrection", note: "翻译完成后检查选择的源语言与输入内容语言类型的不匹配按钮点击计数统计")
/// 首页功能推荐点击计数统计
let homeTouchFunctionRecommendKey: StatisticsEvent    = StatisticsEvent.init(key: "homeTouchFunctionRecommend", note: "首页功能推荐点击计数统计")
/// 首页展示计数统计
let homePageShowKey: StatisticsEvent                  = StatisticsEvent.init(key: "homePageShowKey", note: "首页展示计数统计")

// MARK: 设置页统计事件
/// 设置页订阅点击的计数统计
let settingTouchSubscribeKey: StatisticsEvent         = StatisticsEvent.init(key: "settingTouchSubscribe", note: "设置页订阅点击的计数统计")
/// 设置页订阅恢复购买点击计数统计
let settingTouchRestoreKey: StatisticsEvent           = StatisticsEvent.init(key: "settingTouchRestore", note: "设置页订阅恢复购买点击计数统计")
/// 设置页分享APP的计数统计
let settingShareAPPKey: StatisticsEvent               = StatisticsEvent.init(key: "settingShareApp", note: "设置页分享APP的计数统计")
/// 设置页选择源语言按钮点击计数统计
let settingSwitchSourceLangKey: StatisticsEvent       = StatisticsEvent.init(key: "settingSwtichSourceLanguage", note: "设置页选择源语言按钮点击计数统计")
/// 设置页选择目标语言按钮点击计数统计
let settingSwitchTargetLangKey: StatisticsEvent       = StatisticsEvent.init(key: "settingSwitchTargetLanguage", note: "设置页选择目标语言按钮点击计数统计")
/// 设置页展示计数统计
let settingPageShowKey: StatisticsEvent               = StatisticsEvent.init(key: "settingPageShowKey", note: "设置页展示计数统计")

// MARK: 切换语言统计事件
/// 进入语言列表页的总计数统计
let switchLangPageShowKey: StatisticsEvent            = StatisticsEvent.init(key: "switchLanguagePageShow", note: "进入语言列表页的总计数统计")
/// 进入语言列表页的From计数统计
let switchLangPageFromKey: StatisticsEvent            = StatisticsEvent.init(key: "switchLanguageFromPageShow", note: "进入语言列表页的From计数统计")
/// 进入语言列表页的To计数统计
let switchLangPageToKey: StatisticsEvent              = StatisticsEvent.init(key: "switchLanguageToPageShow", note: "进入语言列表页的To计数统计")
/// 语言列页选择源语言统计(参数: `languageCode`: 选择的语种)
let switchLangPageSourcelangKey: StatisticsEvent      = StatisticsEvent.init(key: "switchLanguageSelectedSourceLanguage", note: "语言列页选择源语言统计(参数: `languageCode`: 选择的语种)")
/// 语言列页选择目标语言统计(参数: `languageCode`: 选择的语种)
let switchLangPageTargetlangKey: StatisticsEvent      = StatisticsEvent.init(key: "switchLanguageSelectedTargetLanguage", note: "语言列页选择目标语言统计(参数: `languageCode`: 选择的语种)")
/// 语言列页选择男女生统计(参数: `sex`: 男生 0 女生 1)
let switchLangPageLanguageVoice: StatisticsEvent      = StatisticsEvent.init(key: "switchLanguageSelectedLanguageVoice", note: "语言列页选择男女生统计(参数: `sex`: 男生 0 女生 1)")
/// 语言列页选择语速统计(参数: `rate`: 语速)
let switchLangPageLanguageRate: StatisticsEvent       = StatisticsEvent.init(key: "swtichLanguageSelectedLangyageRate", note: "语言列页选择语速统计(参数: `rate`: 语速)")

// MARK: 相机页统计事件
/// 相机页展示计数统计
let cameraPageShowKey: StatisticsEvent                = StatisticsEvent.init(key: "cameraPageShow", note: "相机页展示计数统计")
/// 相机页文本拍照计数统计
let cameraTextPhotographKey: StatisticsEvent          = StatisticsEvent.init(key: "cameraTextPhotograph", note: "相机页文本拍照计数统计")
/// 相机页对象拍照计数统计
let cameraObjectPhotographKey: StatisticsEvent        = StatisticsEvent.init(key: "cameraObjecPhotograph", note: "相机页对象拍照计数统计")
/// 相机页文本选择语言列表点击计数统计
let cameraTextTouchLangKey: StatisticsEvent           = StatisticsEvent.init(key: "cameraTextTouchLanguageButton", note: "相机页文本选择语言列表点击计数统计")
/// 相机页对象选择语言列表点击计数统计
let cameraObjectTouchLangKey: StatisticsEvent         = StatisticsEvent.init(key: "cameraObjectTouchLanguageButton", note: "相机页对象选择语言列表点击计数统计")
/// 相机页文本相册点击计数统计
let cameraTextTouchPhotoAlbumKey: StatisticsEvent     = StatisticsEvent.init(key: "cameraTextTouchPhotoAlbum", note: "相机页文本相册点击计数统计")
/// 相机页对象相册点击计数统计
let cameraObjectTouchPhotoAlbumKey: StatisticsEvent   = StatisticsEvent.init(key: "cameraObjectTouchPhotoAlbum", note: "相机页对象相册点击计数统计")
/// 相机页文本翻译点击分享计数统计
let cameraTextShareResultKey: StatisticsEvent         = StatisticsEvent.init(key: "cameraTextShareResult", note: "相机页文本翻译点击分享计数统计")
/// 相机页对象识别点击分享计数统计
let cameraObjectShareResultKey: StatisticsEvent       = StatisticsEvent.init(key: "cameraObjectShareResult", note: "相机页对象识别点击分享计数统计")
/// 相机页文本翻译点击语音播放计数统计
let cameraTextPlayResultKey: StatisticsEvent          = StatisticsEvent.init(key: "cameraTextPlayTranslateResult", note: "相机页文本翻译点击语音播放计数统计")
/// 相机页对象识别点击语音播放计数统计
let cameraObjectPlayResultKey: StatisticsEvent        = StatisticsEvent.init(key: "cameraObjectPlayTranslateResult", note: "相机页对象识别点击语音播放计数统计")
/// 相机页目标语言选择统计(参数: `languageCode`: 选择的语种)
let cameraTargetLangSelectedKey: StatisticsEvent      = StatisticsEvent.init(key: "cameraTargetLanguageSelected", note: "相机页目标语言选择统计(参数: `languageCode`: 选择的语种)")

// MARK: AR页统计事件
/// AR页展示计数统计
let ARPageShowKey: StatisticsEvent                    = StatisticsEvent.init(key: "ARPageShow", note: "AR页展示计数统计")
/// AR页对象保存截图计数统计
let ARPageTouchSnapKey: StatisticsEvent               = StatisticsEvent.init(key: "ARTouchSnap", note: "AR页对象保存截图计数统计")
/// AR页选择语言列表点击计数统计
let ARPageTouchLangKey: StatisticsEvent               = StatisticsEvent.init(key: "ARLanguageSelected", note: "AR页选择语言列表点击计数统计")
/// AR页对象识别结果点击复制计数统计
let ARCopyTranslateResultKey: StatisticsEvent         = StatisticsEvent.init(key: "ARCopyTranslateResult", note: "AR页对象识别结果点击复制计数统计")
/// AR页对象识别结果点击语音播放计数统计
let ARPlayTranslateResultKey: StatisticsEvent         = StatisticsEvent.init(key: "ARPlayTranslateResult", note: "AR页对象识别结果点击语音播放计数统计")

// MARK: 订阅页面统计
/// 订阅页展示次数
let SubpageShowCount: StatisticsEvent                 = StatisticsEvent.init(key: "af_subscribepage_show", note: "订阅页展示次数")
/// 订阅界面点击x进入App事件 (想法：订阅页在哪里弹出的)
let ClosedSubscribePageCount: StatisticsEvent         = StatisticsEvent.init(key: "af_subscribepage_close", note: "订阅界面点击x进入App事件 (想法：订阅页在哪里弹出的)")
/// 订阅按钮点击事件
let SubscribeButtonClickCount: StatisticsEvent        = StatisticsEvent.init(key: "af_subscribe_click", note: "订阅按钮点击事件")
/// 订阅界面点击x进入App时广告请求成功事件
let EnteredSubpageWithADIntersitialExistCount:  StatisticsEvent = StatisticsEvent.init(key: "i_req_subpage_success", note: "订阅界面点击x进入App时广告请求成功事件")

// MARK: 语音页统计事件
/// 1、语音页展示计数统计
let VoicePageShowKey: StatisticsEvent                 = StatisticsEvent.init(key: "VoicePageShowKey", note: "语音页展示计数统计")
/// 2、语音页源语言点击计数统计
let VoiceOriginalLangKey: StatisticsEvent             = StatisticsEvent.init(key: "VoiceOriginalLangKey", note: "语音页源语言点击计数统计")
/// 3、语音页目标语言点击计数统计
let VoiceTargetLangKey: StatisticsEvent               = StatisticsEvent.init(key: "VoiceTargetLangKey", note: "语音页目标语言点击计数统计")
/// 4、语音页源语言录入点击计数统计
let VoiceOriginalRecordKey: StatisticsEvent           = StatisticsEvent.init(key: "VoiceOriginalRecordKey", note: "语音页源语言录入点击计数统计")
/// 5、语音页目标语言录入点击计数统计
let VoiceTargetRecordKey: StatisticsEvent             = StatisticsEvent.init(key: "VoiceTargetRecordKey", note: "语音页目标语言录入点击计数统计")
/// 6、语言页源语言录入翻译结果分享点击计数统计
let VoiceOriginalResultShareKey: StatisticsEvent      = StatisticsEvent.init(key: "VoiceOriginalResultShareKey", note: "语言页源语言录入翻译结果分享点击计数统计")
/// 7、语言页源语言录入翻译结果全屏点击计数统计
let VoiceOriginalResultFullScreenKey: StatisticsEvent = StatisticsEvent.init(key: "VoiceOriginalResultFullScreenKey", note: "语言页源语言录入翻译结果全屏点击计数统计")
/// 8、语言页源语言录入翻译结果收藏点击计数统计
let VoiceOriginalResultCollectKey: StatisticsEvent    = StatisticsEvent.init(key: "VoiceOriginalResultCollectKey", note: "语言页源语言录入翻译结果收藏点击计数统计")
/// 9、语言页源语言录入翻译结果编辑点击计数统计
let VoiceOriginalResultEditKey: StatisticsEvent       = StatisticsEvent.init(key: "VoiceOriginalResultEditKey", note: "语言页源语言录入翻译结果编辑点击计数统计")
/// 10、语言页目标语言录入翻译结果播放点击计数统计
let VoiceOriginalResultPlayKey: StatisticsEvent       = StatisticsEvent.init(key: "VoiceOriginalResultPlayKey", note: "语言页目标语言录入翻译结果播放点击计数统计")
/// 11、语言页目标语言录入翻译结果分享点击计数统计
let VoiceTargetResultShareKey: StatisticsEvent        = StatisticsEvent.init(key: "VoiceTargetResultShareKey", note: "语言页目标语言录入翻译结果分享点击计数统计")
/// 12、语言页目标语言录入翻译结果全屏点击计数统计
let VoiceTargetResultFullScreenKey: StatisticsEvent   = StatisticsEvent.init(key: "VoiceTargetResultFullScreenKey", note: "语言页目标语言录入翻译结果全屏点击计数统计")
/// 13、语言页目标语言录入翻译结果收藏点击计数统计
let VoiceTargetResultCollectKey: StatisticsEvent      = StatisticsEvent.init(key: "VoiceTargetResultCollectKey", note: "语言页目标语言录入翻译结果收藏点击计数统计")
/// 14、语言页目标语言录入翻译结果编辑点击计数统计
let VoiceTargetResultEditKey: StatisticsEvent         = StatisticsEvent.init(key: "VoiceTargetResultEditKey", note: "语言页目标语言录入翻译结果编辑点击计数统计")
/// 15、语言页目标语言录入翻译结果播放点击计数统计
let VoiceTargetResultPlayKey: StatisticsEvent         = StatisticsEvent.init(key: "VoiceTargetResultPlayKey", note: "语言页目标语言录入翻译结果播放点击计数统计")

// MARK: 更多
// 1、更多页按钮点击计数统计，配置indexType对应每个条目的类型
//let MoreHomePageClickKey: StatisticsEvent             = StatisticsEvent.init(key: "MoreHomePageClickKey", note: "更多页按钮点击计数统计，配置indexType对应每个条目的类型")
//事件名称: MoreHomePageClickKey
//事件参数indexType:
//MoreTodayWidgetKey
//MoreFavoriteKey
//MoreHistoryKey
//MorePhrasebookKey
//MoreSiriShortcutKey
//MoreFlashCardKey
//MoreFlashCardWidgetKey
//MoreShareExtensionKey
let MoreHomePageTodayWidgetKey: StatisticsEvent       = StatisticsEvent.init(key: "MoreHomePageTodayWidgetKey", note: "更多页-TodayWidget按钮点击计数统计")
let MoreHomePageFavoriteKey: StatisticsEvent          = StatisticsEvent.init(key: "MoreHomePageFavoriteKey", note: "更多页-Favorite按钮点击计数统计")
let MoreHomePageHistoryKey: StatisticsEvent           = StatisticsEvent.init(key: "MoreHomePageHistoryKey", note: "更多页-History按钮点击计数统计")
let MoreHomePagePhrasebookKey: StatisticsEvent        = StatisticsEvent.init(key: "MoreHomePagePhrasebookKey", note: "更多页-Phrasebook按钮点击计数统计")
let MoreHomePageSiriShortcutKey: StatisticsEvent      = StatisticsEvent.init(key: "MoreHomePageSiriShortcutKey", note: "更多页-SiriShortcut按钮点击计数统计")
let MoreHomePageFlashCardKey: StatisticsEvent         = StatisticsEvent.init(key: "MoreHomePageFlashCardKey", note: "更多页-Flashcard按钮点击计数统计")
let MoreHomePageFlashCardWidgetKey: StatisticsEvent   = StatisticsEvent.init(key: "MoreHomePageFlashCardWidgetKey", note: "更多页-FlashcardWidget按钮点击计数统计")
let MoreShareExtensionKey: StatisticsEvent            = StatisticsEvent.init(key: "MoreShareExtensionKey", note: "更多页-ShareExtension按钮点击计数统计")

// MARK: 历史页面
// 1、历史页收藏点击计数统计，配置controlType对应收藏取消
// 参数controlType: 收藏 like  取消收藏 dislike
let HistoryPageCollectKey: StatisticsEvent            = StatisticsEvent.init(key: "HistoryPageCollectKey", note: "历史页收藏/取消收藏点击计数统计")
// 2、历史页复制点击计数统计
let HistoryPageCopyKey: StatisticsEvent               = StatisticsEvent.init(key: "HistoryPageCopyKey", note: "历史页复制点击计数统计")

// MARK: 收藏页面
// 1、收藏页收藏点击计数统计，配置controlType对应收藏取消
//参数controlType: 取消收藏 dislike  说明：收藏页面只有取消收藏
let FavoritePageCollectKey: StatisticsEvent           = StatisticsEvent.init(key: "FavoritePageCollectKey", note: "收藏页取消收藏点击计数统计")
// 2、收藏页复制点击计数统计
let FavoritePageCopyKey: StatisticsEvent              = StatisticsEvent.init(key: "FavoritePageCopyKey", note: "收藏页复制点击计数统计")

// MARK: 小组件
//1、中组件点击计数统计
let MediumWidgetOpenAppKey: StatisticsEvent           = StatisticsEvent.init(key: "MediumWidgetOpenAppKey", note: "中组件点击计数统计")
//2、小组件点击计数统计
let SmallWidgetOpenAppKey: StatisticsEvent            = StatisticsEvent.init(key: "SmallWidgetOpenAppKey", note: "小组件点击计数统计")


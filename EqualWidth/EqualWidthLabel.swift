// Created by Bohua Zheng on 2022/1/14.

import UIKit
import CoreText

class JSONViewTextView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .clear
  }

  var textAlignment: NSTextAlignment = .left

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var text: Text? {
    didSet {
      setNeedsDisplay()
    }
  }

  override func draw(_ rect: CGRect) {
    guard let text = text, let context = UIGraphicsGetCurrentContext() else {
      return
    }

    context.translateBy(x: 0, y: bounds.height)
    context.scaleBy(x: 1, y: -1)
    context.textMatrix = .identity

    var previousLineOffset: CGFloat = 0
    for (index, ctLine) in text.ctLines.enumerated() {
      let lineRect = text.ctLineIntrinsicRects[index]
      let originX = textAlignment == .right ? rect.width - lineRect.width : 0
      // let text in center vertically when draw rect is larger than text bounds
      let centerVerticallyOffset = (rect.height - text.intrinsicRect.height) / 2
      // CTLineDraw from bottom to top, we need to mirror it.
      let lineOriginY = text.intrinsicRect.height - lineRect.height - lineRect.origin.y
      context.textPosition = CGPoint(x: originX, y: centerVerticallyOffset + lineOriginY - previousLineOffset)
      CTLineDraw(ctLine, context)
      previousLineOffset += lineRect.height + 4
    }
  }

}

extension JSONViewTextView {
  struct Text {
    init(attributedString: NSAttributedString) {
      self.attributedString = attributedString

      framesetter = CTFramesetterCreateWithAttributedString(attributedString)
      let frameSize = CTFramesetterSuggestFrameSizeWithConstraints(
        framesetter, CFRangeMake(0, 0),
        nil, CGSize(width: 300, height: CGFloat.infinity),
        nil)
      let rect = CGRect(origin: .zero, size: frameSize)
      let path = CGMutablePath()
      path.addRect(rect)
      let ctFrame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: 0), path, nil)
      let ctLines = CTFrameGetLines(ctFrame)

      var tempCTLines = [CTLine]()
      var tempCTLineIntrinsicRects = [CGRect]()
      var maxWidth: CGFloat = 0
      var height: CGFloat = 0
      let spacing: CGFloat = 4

      for i in 0 ..< CFArrayGetCount(ctLines) {
        let ctLinePtr = CFArrayGetValueAtIndex(ctLines, i)!
        let ctLine = unsafeBitCast(ctLinePtr, to: CTLine.self)
        let lineWidth = CTLineGetTypographicBounds(ctLine, nil, nil, nil)
        let glyphPathBounds = CTLineGetBoundsWithOptions(ctLine, .useGlyphPathBounds)
        let r = CGRect(
          x: glyphPathBounds.origin.x,
          y: glyphPathBounds.origin.y,
          width: CGFloat(lineWidth),
          height: glyphPathBounds.height)

        tempCTLines.append(ctLine)
        tempCTLineIntrinsicRects.append(r)

        print(r.width)
        maxWidth = max(maxWidth, r.width)
        height += r.height + spacing
      }

      print("maxWidth: \(maxWidth)")

      // 核心代码
      // 除了最后一行，每行的宽度都有细微的差别，我们在这里重新调整下行宽。
      let lastIndex = tempCTLines.count - 1
      tempCTLines = tempCTLines.enumerated().map { index, line in
        CTLineCreateJustifiedLine(line, index == lastIndex ? 0 : 1, maxWidth)!
      }

      self.ctLines = tempCTLines
      self.ctLineIntrinsicRects = tempCTLineIntrinsicRects

      intrinsicRect = CGRect(
        x: 0,
        y: 0,
        width: maxWidth,
        height: height)
    }

    let attributedString: NSAttributedString
    let intrinsicRect: CGRect

    fileprivate let framesetter: CTFramesetter
    fileprivate let ctLines: [CTLine]
    fileprivate let ctLineIntrinsicRects: [CGRect]
  }
}

extension String {
  func apply(_ attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
    NSAttributedString(string: self, attributes: attributes)
  }
}


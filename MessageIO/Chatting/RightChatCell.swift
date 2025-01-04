//
//  RightChatCell.swift
//  MessageIO
//
//  Copyright (c) 2024 z-wook. All right reserved.
//

import SnapKit
import UIKit

final class RightChatCell: UICollectionViewCell {
    static let identifier = "RightChattingCell"
    
    private let bubbleImageView: UIImageView = {
        let view = UIImageView()
        view.image = .messageRight
        view.contentMode = .scaleToFill
        view.clipsToBounds = true
        return view
    }()
    
    private let chatLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.regular16Font
        label.textColor = ThemeColors.blackColor
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.light13Font
        label.textColor = ThemeColors.systemGray2Color
        label.textAlignment = .right
        label.numberOfLines = 0
        return label
    }()
    
    private let messageBoxView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .trailing
        view.distribution = .fill
        view.spacing = AppConstraint.size10
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RightChatCell {
    func setData(data: Chat?) {
        chatLabel.text = data?.chat
        timeLabel.text = data?.time
    }
}

private extension RightChatCell {
    func setUI() {
        contentView.addSubview(messageBoxView)
        
        [UIView(), timeLabel, bubbleImageView].forEach {
            messageBoxView.addArrangedSubview($0)
        }
        
        bubbleImageView.addSubview(chatLabel)
        
        messageBoxView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(AppConstraint.size8)
        }
        
        timeLabel.snp.makeConstraints {
            $0.width.equalTo(AppConstraint.size50)
        }
        
        bubbleImageView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
        }
        
        chatLabel.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview().inset(AppConstraint.size8)
            $0.trailing.equalToSuperview().inset(AppConstraint.size14)
            $0.width.lessThanOrEqualTo(AppConstraint.chatLabelMaxWidth) // 최대 폭
        }
    }
}

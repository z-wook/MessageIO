//
//  LeftChatCell.swift
//  MessageIO
//
//  Copyright (c) 2024 z-wook. All right reserved.
//

import SnapKit
import UIKit

final class LeftChatCell: UICollectionViewCell {
    static let identifier = "LeftChatCell"
    
    private let profileImageView: UIImageView = {
        let view = UIImageView()
        view.image = .defaultProfile
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        return view
    }()
    
    private let bubbleImageView: UIImageView = {
        let view = UIImageView()
        view.image = .messageLeft
        view.contentMode = .scaleToFill
        view.clipsToBounds = true
        return view
    }()
    
    private let profileNameLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.light15Font
        label.textColor = ThemeColors.systemGray2Color
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
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
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private let messageBoxView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .leading
        view.distribution = .fill
        view.spacing = AppConstraint.size10
        return view
    }()
    
    private let chatVStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .leading
        view.distribution = .fill
        view.spacing = AppConstraint.size10
        return view
    }()
    
    private let chatHStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .bottom
        view.distribution = .fill
        view.spacing = AppConstraint.size8
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

extension LeftChatCell {
    func setData(data: Chat) {
        profileImageView.image = data.profileImg ?? .defaultProfile
        profileNameLabel.text = data.name
        chatLabel.text = data.chat
        timeLabel.text = data.time
    }
    
    private func setUI() {
        contentView.addSubview(messageBoxView)
        
        [profileImageView, chatVStackView].forEach {
            messageBoxView.addArrangedSubview($0)
        }
        
        [profileNameLabel, chatHStackView].forEach {
            chatVStackView.addArrangedSubview($0)
        }
        
        [bubbleImageView, timeLabel].forEach {
            chatHStackView.addArrangedSubview($0)
        }
        
        bubbleImageView.addSubview(chatLabel)
        
        messageBoxView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(AppConstraint.size8)
        }
        
        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(AppConstraint.size40)
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
        }
        
        profileNameLabel.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(AppConstraint.size20)
        }
        
        chatLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(AppConstraint.size14)
            $0.top.trailing.bottom.equalToSuperview().inset(AppConstraint.size8)
            $0.width.lessThanOrEqualTo(AppConstraint.chatLabelMaxWidth) // 최대 폭
        }
        
        timeLabel.snp.makeConstraints {
            $0.width.equalTo(AppConstraint.size50)
        }
    }
}

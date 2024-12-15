//
//  LeftChattingCell.swift
//  MessageIO
//
//  Copyright (c) 2024 z-wook. All right reserved.
//

import SnapKit
import UIKit

final class LeftChattingCell: UICollectionViewCell {
    static let identifier = "LeftChattingCell"
    
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
        label.font = ThemeFont.profileNameFont
        label.textColor = ThemeColors.profileNameColor
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    private let chattingLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.chattingLabelFont
        label.textColor = ThemeColors.chattingColor
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.timeLabelFont
        label.textColor = ThemeColors.timeColor
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private let messageBoxView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .leading
        view.distribution = .fill
        view.spacing = AppConstraint.spacing10
        return view
    }()
    
    private let chattingVStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .leading
        view.distribution = .fill
        view.spacing = AppConstraint.chattingVStackSpacing
        return view
    }()
    
    private let chattingHStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .bottom
        view.distribution = .fill
        view.spacing = AppConstraint.spacing8
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setUI()
    }
}

extension LeftChattingCell {
    func setData(data: ChattingModel?) {
        profileImageView.image = data?.profileImg ?? .defaultProfile
        profileNameLabel.text = data?.name
        chattingLabel.text = data?.chatting
        timeLabel.text = "13:42"
    }
    
    func setUI() {
        contentView.addSubview(messageBoxView)
        
        [profileImageView, chattingVStackView].forEach {
            messageBoxView.addArrangedSubview($0)
        }
        
        [profileNameLabel, chattingHStackView].forEach {
            chattingVStackView.addArrangedSubview($0)
        }
        
        [bubbleImageView, timeLabel].forEach {
            chattingHStackView.addArrangedSubview($0)
        }
        
        bubbleImageView.addSubview(chattingLabel)
        
        messageBoxView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(AppConstraint.messageBoxInset)
        }
        
        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(AppConstraint.profileImageSize)
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
        }
        
        profileNameLabel.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(AppConstraint.profileNameLabelSize)
        }
        
        chattingLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(AppConstraint.chattingLabelLeading)
            $0.top.trailing.bottom.equalToSuperview().inset(AppConstraint.chattingLabelInset)
            $0.width.lessThanOrEqualTo(AppConstraint.chattingLabelMaxWidth) // 최대 폭
        }
        
        timeLabel.snp.makeConstraints {
            $0.width.equalTo(AppConstraint.timeLabelWidth)
        }
    }
}

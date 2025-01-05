//
//  ChatListCell.swift
//  MessageIO
//
//  Copyright (c) 2025 z-wook. All right reserved.
//

import SnapKit
import UIKit

final class ChatListCell: UICollectionViewCell {
    static let identifier: String = "ChatListCell"
    
    private let profileImageView: UIImageView = {
        let view = UIImageView()
        view.image = .defaultProfile
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.medium16Font
        label.textColor = ThemeColors.whiteColor
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.regular14Font
        label.textColor = ThemeColors.systemGray2Color
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.regular14Font
        label.textColor = ThemeColors.systemGray2Color
        label.textAlignment = .right
        label.numberOfLines = 1
        return label
    }()
    
    private let hStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fill
        view.spacing = AppConstraint.size8
        return view
    }()
    
    private let vStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .leading
        view.distribution = .fill
        view.spacing = 0
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ChatListCell {
    func setData(data: Chat) {
        profileImageView.image = data.profileImg ?? .defaultProfile
        titleLabel.text = data.name
        subTitleLabel.text = data.chat
        timeLabel.text = data.time
    }
    
    private func setUI() {
        contentView.addSubview(hStackView)
        
        [profileImageView, vStackView, timeLabel].forEach {
            hStackView.addArrangedSubview($0)
        }
        
        [titleLabel, subTitleLabel].forEach {
            vStackView.addArrangedSubview($0)
        }
        
        hStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(AppConstraint.size16)
        }
        
        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(AppConstraint.size50)
        }
    }
}

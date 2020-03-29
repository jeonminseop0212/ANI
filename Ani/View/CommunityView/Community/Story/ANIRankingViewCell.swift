//
//  ANIRankingViewCell.swift
//  Ani
//
//  Created by jeonminseop on 2018/11/17.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

protocol ANIRankingViewCellDelegate {
  func didSelectRankingCell(rankingStory: FirebaseStory, ranking: Int)
}

class ANIRankingViewCell: UITableViewCell {
  
  private weak var storyRankingView: ANIStoryRankingView?
  
  var rankingStories: [FirebaseStory]? {
    didSet {
      guard let storyRankingView = self.storyRankingView,
            let rankingStories = self.rankingStories else { return }
      
      storyRankingView.rankingStories = rankingStories
    }
  }
  
  var delegate: ANIRankingViewCellDelegate?
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.backgroundColor = ANIColor.bg
    self.selectionStyle = .none
    
    //storyRankingView
    let storyRankingView = ANIStoryRankingView()
    storyRankingView.delegate = self
    addSubview(storyRankingView)
    storyRankingView.topToSuperview(offset: 10.0)
    storyRankingView.leftToSuperview()
    storyRankingView.rightToSuperview()
    storyRankingView.bottomToSuperview(offset: -10.0, priority: .defaultHigh)
    let height = ANIStoryRankingCell.share.RANKING_COLLECTION_VIEW_CELL_WIDHT + ANIStoryRankingCell.share.STORY_LABEL_HEIHGT + ANIStoryRankingCell.share.PROFILE_IMAGE_VIEW_HEIGHT + ANIStoryRankingCell.share.MARGIN
    storyRankingView.height(height)
    self.storyRankingView = storyRankingView
  }
}

//MARK: ANIStoryRankingViewDelegate
extension ANIRankingViewCell: ANIStoryRankingViewDelegate {
  func didSelectRankingCell(rankingStory: FirebaseStory, ranking: Int) {
    self.delegate?.didSelectRankingCell(rankingStory: rankingStory, ranking: ranking)
  }
}

//
//  AudioReceivedPlaybackManager.swift
//  Madrasati
//
//  Created by Maher Jaber on 04/01/2024.
//  Copyright © 2024 IQUAD. All rights reserved.
//

import Foundation

class AudioReceivedPlaybackManager {
    static let shared = AudioReceivedPlaybackManager()
    weak var currentPlayingCell: AudioReceivedTableViewCell?

    func playAudio(for cell: AudioReceivedTableViewCell) {
        // Stop any currently playing audio
        if let playingCell = currentPlayingCell {
            playingCell.stopAudio()
        }
        
        // Set the new cell as the one that should be playing audio
        currentPlayingCell = cell
        
        // Start playing the new audio
        cell.playAudio()
    }

    func stopAudio() {
        currentPlayingCell?.stopAudio()
        currentPlayingCell = nil
    }
}

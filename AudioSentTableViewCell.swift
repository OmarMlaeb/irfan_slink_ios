//
//  AudioSentTableViewCell.swift
//  Madrasati
//
//  Created by Maher Jaber on 03/01/2024.
//  Copyright © 2024 IQUAD. All rights reserved.
//

import UIKit
import AVFoundation

class AudioSentTableViewCell: UITableViewCell, AVAudioPlayerDelegate {
    
    @IBOutlet weak var sentDate: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var audioSlider: UISlider!
    @IBOutlet weak var view: UIView!
    
    var audioPlayer: AVAudioPlayer?
    var timer: Timer?
    var url: URL?

    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        print("player player")
        if audioPlayer?.isPlaying == true {
            audioPlayer?.pause()
            updateButtonToPlayState()
            AudioPlaybackManager.shared.currentPlayingCell = nil
            
            if #available(iOS 13.0, *) {
                let image = UIImage(systemName: "play")?.withRenderingMode(.alwaysTemplate)
                playButton.setImage(image, for: .normal)
                playButton.tintColor = UIColor.white
            }
        } else {
//            audioPlayer?.play()
            AudioPlaybackManager.shared.playAudio(for: self)

            if #available(iOS 13.0, *) {
                let image = UIImage(systemName: "pause")?.withRenderingMode(.alwaysTemplate)
                playButton.setImage(image, for: .normal)
                playButton.tintColor = UIColor.white

            }

            startTimer()
        }
    }
   
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        audioPlayer?.currentTime = TimeInterval(sender.value)
    }
    
    func playAudio() {
        audioPlayer?.play()
    }

    func stopAudio() {
        audioPlayer?.stop()
        updateButtonToPlayState()
        timer?.invalidate()
        timer = nil
        audioSlider.value = 0 // Reset the slider to the start
    }
    
    func updateButtonToPlayState() {
        DispatchQueue.main.async {
            if #available(iOS 13.0, *) {
                self.playButton.setImage(UIImage(systemName: "play"), for: .normal)
            }
        }
    }

    func updateButtonToPauseState() {
        DispatchQueue.main.async {
            if #available(iOS 13.0, *) {
                self.playButton.setImage(UIImage(systemName: "pause"), for: .normal)
            }
        }
    }
    
    func configureCell(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        audioSlider.tintColor = UIColor.white
        audioSlider.value = 0
        self.url = URL(string: urlString)!
        if #available(iOS 13.0, *) {
            let image = UIImage(systemName: "play")?.withRenderingMode(.alwaysTemplate)
            playButton.setImage(image, for: .normal)
            playButton.tintColor = UIColor.white
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }

            DispatchQueue.main.async {
                do {
                    self?.audioPlayer = try AVAudioPlayer(data: data)
                    self?.audioPlayer?.delegate = self // Set the delegate to self
                    self?.audioSlider.maximumValue = Float(self?.audioPlayer?.duration ?? 0)
                    self?.audioPlayer?.prepareToPlay()
                    
                } catch {
                    // Handle the error
                    print("Error initializing the audio player: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    
    func startTimer() {
          // Invalidate existing timer if any
          timer?.invalidate()
          
          timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
              self?.updateSlider()
          }
      }
    
    func updateSlider() {
        // Update the slider without triggering `sliderValueChanged`
        // Disable the slider's event temporarily while updating its value
        audioSlider.isUserInteractionEnabled = false
        if let currentTime = audioPlayer?.currentTime {
            audioSlider.value = Float(currentTime)
        }
        audioSlider.isUserInteractionEnabled = true
    }
    
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        if flag {
//            DispatchQueue.main.async { [weak self] in
//                if #available(iOS 13.0, *) {
//                    self?.playButton.setImage(UIImage(systemName: "play"), for: .normal)
//                }
//                self?.timer?.invalidate()
//                self?.timer = nil
//                self?.audioSlider.value = 0 // Reset the slider to the start
//            }
//        }
//    }

    // And update the delegate method as well
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            updateButtonToPlayState()
            timer?.invalidate()
            timer = nil
            audioSlider.value = 0 // Reset the slider to the start
            AudioPlaybackManager.shared.currentPlayingCell = nil
        }
    }
    
    // Remember to invalidate the timer when the cell is not visible
    override func prepareForReuse() {
        super.prepareForReuse()
        timer?.invalidate()
        timer = nil
        audioPlayer?.stop()
        if #available(iOS 13.0, *) {
            let image = UIImage(systemName: "play")?.withRenderingMode(.alwaysTemplate)
            playButton.setImage(image, for: .normal)
            playButton.tintColor = UIColor.white
        }
        // Reset play button and slider
    }
}

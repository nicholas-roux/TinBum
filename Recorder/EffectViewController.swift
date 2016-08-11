//
//  EffectViewController.swift
//  Effect
//
//  Created by Nicholas Roux on 7/27/16.
//  Copyright © 2016 Nicholas Roux. All rights reserved.
//

import UIKit
import AudioKit
import AVFoundation

class RecordViewController: UIViewController {
    
    @IBOutlet var effectButton: UISwitch!
    @IBOutlet var noiseButton: UISwitch!
    @IBOutlet var sensitivitySlider: UISlider!
    
    var mic: AKMicrophone!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Set the Audio Session of Audiokit to "Play and Record"
        let audioSession = AVAudioSession.sharedInstance()
        do {
            
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            
        } catch {
        
        }
        
        /// Set universal variable 'mic' as the devices microphone input
        mic = AKMicrophone()
        
             ///---------------------------------------------------------------///
            ///------------------------AUDIOKIT SETTINGS----------------------///
        
            /// .shortest is 32 samples = 0.72 ms @ 44100 Hz
            AKSettings.bufferLength = .Shortest
        
            /// Allows AudioKit to send Notifications
            AKSettings.notificationsEnabled = true
        
            /// Whether to DefaultToSpeaker when audio input is enabled
            AKSettings.defaultToSpeaker = true
        
            /// Whether to allow audio playback to override the mute setting
            AKSettings.playbackWhileMuted = true
        
            /// Whether we should be listening to audio input (microphone)
            AKSettings.audioInputEnabled = true
        
            /// Number of audio channels: 2 for stereo, 1 for mono
            AKSettings.numberOfChannels = 1
        
            /// The sample rate in Hertz
            AKSettings.sampleRate = 44100
        
            ///---------------------------------------------------------------///
        
        /// Run the vanilla mic input effect
        vanillaEffect()

    }
    
     ///--------------------------------------------------------------///
    ///-------------------------Effect Toggle------------------------///
    
    
    /// When the effect toggle is engaged by the user
    @IBAction func effect(sender: UISwitch) {
        
        /// Stop AudioKit to apply effects to the microphone input
        AudioKit.stop()

        /// Check if the effect button is on - the button is turned off by default
        if effectButton!.on {
            
            /// Check if the noise button is also turned on - both should not be on at the same time
            if noiseButton!.on {
                
                    /// Set alert saying that both the effect and noise generation cannot happen simultaneously
                    let alert = UIAlertController(title: "Whoops!",
                                                  message: "You cannot enable the effect with the noise generator activated", preferredStyle: .Alert)
                
                    /// Set the user response to be aware of this condition
                    let action = UIAlertAction(title: "Disable noise generator", style: .Default, handler: nil)
                
                    /// Add the user response button to the alert message
                    alert.addAction(action)
                
                    /// Run the alert message
                    presentViewController(alert, animated: true, completion: {
                        
                        /// Disable the noise generator toggle
                        self.noiseButton.setOn(false, animated: true)
                        
                        /// Run the Effect
                        self.soundEffect()
                    })
            
                
            
            /// If the noise button is turned off, proceed with effect
            } else {
                
                /// Run the Effect
                soundEffect()
            
            }
            
        /// Otherwise if the effect button is not turned on
        } else {
            
            /// Run the Effect
            vanillaEffect()
            
        }
        
    }
    
    ///---------------------------------------------------------------///
    
     ///--------------------------------------------------------------///
    ///-------------------------Noise Toggle-------------------------///
    
    /// When the noise toggle is engaged by the user
    @IBAction func noise(sender: UISwitch) {
        
        /// Stop AudioKit to apply apply noise based on the db of the microphone input
        AudioKit.stop()

        /// Check if the noise button is on - the button is turned off by default
        if noiseButton!.on {
            
            /// Check if the effect button is also turned on - both should not be on at the same time
            if effectButton!.on {
                
                /// Set alert saying that both the effect and noise generation cannot happen simultaneously
                let alert = UIAlertController(title: "Whoops!",
                                              message: "You cannot enable the noise generator with the effect activated", preferredStyle: .Alert)
                
                /// Set the user response to be aware of this condition
                let action = UIAlertAction(title: "Disable effect", style: .Default, handler: nil)
                
                /// Add the user response button to the alert message
                alert.addAction(action)
                
                /// Run the alert message
                presentViewController(alert, animated: true, completion: {
                    
                    /// Disable the effect toggle
                    self.effectButton.setOn(false, animated: true)
                    
                    /// Run the Effect
                    self.noiseEffect()
                })
                
            /// If the effect button is turned off, proceed with noise generation
            } else {
                
                /// Run the Effect
                noiseEffect()
                
            }
            
        /// Otherwise if the noise button is not turned on
        } else {
            
            /// Run the Effect
            vanillaEffect()
        
        }
        
    }
    
    ///---------------------------------------------------------------///
    
    ///-------------------------------------------------------------///
    ///----------------------Sensitivity Slider---------------------///
    
    @IBAction func sliderMoved(slider: UISlider) {
        
        AudioKit.stop()
        
        /// Mix the mic channels into 1
        let micMixer = AKMixer(mic)
        
        /// Convert slider value type from 'float' to 'double'
        let sliderValue = Double (slider.value)
        
        /// Set the volume of the mixer to the value of the slider
        micMixer.volume = sliderValue
        
        /// If the effect button is on - apply the microphone sensitivity to the mic input of the sound effect
        if effectButton!.on {
            
            /// Run the Effect
            soundEffect()
        }
        
        /// If the noise button is on - apply the microphone sensitivity to the mic input of the noise generator
        else if noiseButton!.on {
            
            /// Run the Effect
            noiseEffect()
            
        }
        
        /// Otherwise - apple the microphone sensitivity to the mic input
        else {
            
            /// Run the Effect
            vanillaEffect()
            
        }
    }
    
    ///---------------------------------------------------------------///
    
    
    
    
    
     ///--------------------------------------------------------------///
    ///---------------------------Functions--------------------------///
    
    
    /// Vanilla sound from mic
    ///-----------------------///
    func vanillaEffect() {
        
        /// Mix the mic channels into 1
        let micMixer = AKMixer(mic)
        
        /// Convert slider value type from 'float' to 'double'
        let sliderValue = Double (sensitivitySlider.value)
        
        /// Set the volume of the mixer to the value of the slider
        micMixer.volume = sliderValue
        
        /// Set the audio output to the original mic input
        AudioKit.output = micMixer
        
        /// Initialize AudioKit
        AudioKit.start()
    }
    
    /// Sound Effect - currently low pass filter
    ///-----------------------///
    func soundEffect() {
        
        /// Mix the mic channels into 1
        let micMixer = AKMixer(mic)
        
        /// Convert slider value type from 'float' to 'double'
        let sliderValue = Double (sensitivitySlider.value)
        
        /// Set the volume of the mixer to the value of the slider
        micMixer.volume = sliderValue
        
        /// Use low-pass filter on mic input
        let lowPassFilter = AKLowPassFilter(micMixer)
        
        /// Low-pass filter settings
        lowPassFilter.cutoffFrequency = 2000 // Hz
        lowPassFilter.resonance = 0 // dB
        
        /// Set the audio output to the low-pass filtered mic input
        AudioKit.output = lowPassFilter
        
        /// Intialize AudioKit
        AudioKit.start()
    }
    
    
    /// Noise generator - generates pink and white noise, filters it through a high pass filter and mixes it with the microphone input
    ///-----------------------///
    func noiseEffect() {
        
        /// Mix the mic channels into 1
        let micMixer = AKMixer(mic)
        
        /// Convert slider value type from 'float' to 'double'
        let sliderValue = Double (sensitivitySlider.value)
        
        /// Set the volume of the mixer to the value of the slider
        micMixer.volume = sliderValue
        
        /// Generate pink noise
        let pink = AKPinkNoise(amplitude: 1)
        
        /// Generate white noise
        let white = AKWhiteNoise(amplitude: 1)
        
        /// Mix the white and the pink noise
        let pinkWhiteMixer = AKDryWetMixer(pink, white, balance: 0)
        
        /// Filter the pink and white noise mix through a high pass filter
        let filter = AKHighPassFilter(pinkWhiteMixer)
        
        filter.cutoffFrequency = 6000 // Hz
        filter.resonance = 0 // dB
        
        /// Mix the generated noise with the mic input
        let micNoiseMix = AKMixer(filter, micMixer)
        
        /// Set the audio output to the low-pass filtered mic input
        AudioKit.output = micNoiseMix
        
        /// Intialize AudioKit
        AudioKit.start()
        
        /// Initialize pink noise
        pink.start()
        
        /// Initialize white noise
        white.start()
        
    }
    
    ///---------------------------------------------------------------///
    
   }


import Cocoa

public class Scoreboard: NSVisualEffectView {
    
    public static var shared: Scoreboard!
    
    //Holding views
    private var userScoreView: ScoreView!
    private var opposingScoreView: ScoreView!
    private var clockView: ClockView!
    
    public init(frame frameRect: NSRect, withTotalTime time: TimeInterval) {
        super.init(frame: frameRect)

        self.wantsLayer = true
        self.layer?.cornerRadius = frameRect.height / 2
        
        self.material = NSVisualEffectView.Material.dark
        self.blendingMode = .withinWindow
                
        let viewWidth = frameRect.width / 3
        
        userScoreView = ScoreView(frame: NSRect(x: 0, y: 0, width: viewWidth, height: frameRect.height), isUserTeam: true)
        opposingScoreView = ScoreView(frame: NSRect(x: userScoreView.frame.maxX, y: 0, width: viewWidth, height: frameRect.height), isUserTeam: false)
        clockView = ClockView(frame: NSRect(x: opposingScoreView.frame.maxX, y: 0, width: viewWidth, height: frameRect.height), withTotalTime: time)
        
        self.addSubview(userScoreView)
        self.addSubview(opposingScoreView)
        self.addSubview(clockView)
    }
    
    public func startTimer() {
        self.clockView.startTimer()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


fileprivate class ScoreView: NSView {
    private var teamNameLabel: NSTextField!
    private var scoreLabel: NSTextField!
    private var scoreAnimationLabel: NSTextField!
    
    init(frame frameRect: NSRect, isUserTeam isOnUserTeam: Bool) {
        super.init(frame: frameRect)
        
        self.wantsLayer = true
        
        if isOnUserTeam {
            //Add observer for the userTeamGoalScored notification.
            NotificationCenter.default.addObserver(self, selector: #selector(self.scoreGoal), name: .userTeamGoalScored, object: nil)
        }
        else {
            //Add observer for the opposingTeamGoalScored notification.
            NotificationCenter.default.addObserver(self, selector: #selector(self.scoreGoal), name: .opposingTeamGoalScored, object: nil)
        }
        
        //Setting up the team name label
        teamNameLabel = NSTextField(labelWithString: isOnUserTeam ? "Home" : "Away")
        teamNameLabel.textColor = .white
        teamNameLabel.font = NSFont.systemFont(ofSize: frameRect.height * 0.6, weight: NSFont.Weight.regular)
        teamNameLabel.frame = NSRect(x: 0, y: -2.5, width: frameRect.width * 0.7, height: frameRect.height)
        teamNameLabel.alignment = .center
        self.addSubview(teamNameLabel)
        
        //Setting up the team's score label
        scoreLabel = NSTextField(labelWithString: "0")
        scoreLabel.font = NSFont.systemFont(ofSize: frameRect.height * 0.6, weight: NSFont.Weight.bold)
        scoreLabel.alignment = .right
        scoreLabel.textColor = .white
        scoreLabel.frame = NSRect(x: teamNameLabel.frame.maxX, y: -2.5, width: frameRect.width * 0.3, height: frameRect.height)
        self.addSubview(scoreLabel)
        
    }
    
    @objc private func scoreGoal() {
        let currentScore = Int(self.scoreLabel.stringValue)!
        NSAnimationContext.runAnimationGroup({
            context in
            context.duration = 0.175
            self.scoreLabel.alphaValue = 0
        }, completionHandler: {
            self.scoreLabel.stringValue = "\(currentScore + 1)"
            NSAnimationContext.runAnimationGroup({
                context in
                context.duration = 0.175
                self.scoreLabel.alphaValue = 1
            }, completionHandler: nil)
        })
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class ClockView: NSView {
    
    private var timer: Timer!
    private var currentTime: TimeInterval!
    private var timeLabel: NSTextField!
    
    init(frame frameRect: NSRect, withTotalTime time: TimeInterval) {
        super.init(frame: frameRect)
        
        self.currentTime = time
        
        //Setting and adding the time label
        self.timeLabel = NSTextField(labelWithString: self.currentTime.string)
        self.timeLabel.font = NSFont.systemFont(ofSize: frameRect.height * 0.6, weight: NSFont.Weight.regular)
        self.timeLabel.textColor = .white
        self.timeLabel.alignment = .center
        self.timeLabel.frame = self.bounds
        self.timeLabel.frame.origin.y = -2.5
        self.addSubview(timeLabel)
        
        //Add the observers to start and stop the clock
        NotificationCenter.default.addObserver(self, selector: #selector(self.pauseTimer), name: .userTeamGoalScored, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.pauseTimer), name: .opposingTeamGoalScored, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.startTimer), name: .didReturnToPlay, object: nil)
        
    }
    
    @objc fileprivate func startTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    
    @objc private func pauseTimer() {
        self.timer.invalidate()
        self.timer = nil
    }
    
    @objc private func update() {
        self.currentTime = self.currentTime - 0.01
        self.timeLabel.stringValue = self.currentTime.string
        if Int(self.currentTime) == 0 {
            self.timer.invalidate()
            self.timer = nil
            NotificationCenter.default.post(name: .gameDidEnd, object: nil)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//Extending Notification.Name
public extension Notification.Name {
    static let userTeamGoalScored = Notification.Name("userTeamGoalScored")
    static let opposingTeamGoalScored = Notification.Name("opposingTeamGoalScored")
    static let didReturnToPlay = Notification.Name("didReturnToPlay")
    static let gameDidEnd = Notification.Name("gameDidEnd")
}

//Extending TimeInterval
public extension TimeInterval {
    public init (withMinutes minutes: Int, andSeconds seconds: Int) {
        let secondsFromMinutes = minutes * 60
        self = Double(secondsFromMinutes + seconds)
    }
    
    var string: String {
        if self > 60.0 {
            let minutes = Int(self / 60.0)
            let seconds = Int(self.truncatingRemainder(dividingBy: 60.0))
            let secondsString = String(format: "%02d", seconds)
            
            return "\(minutes):\(secondsString)"
        }
        let str = String(format: "%04.2f", self)
        return ":\(str)"
    }
}

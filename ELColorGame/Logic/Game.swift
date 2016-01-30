//
//  Created by Dariusz Rybicki on 27/11/15.
//  Copyright © 2015 EL Passion. All rights reserved.
//

import Foundation

class Game {

    private let difficultyLevel = DifficultyLevel()
    private let board: Board
    private var score: Int = 0 {
        didSet {
            delegate?.gameDidUpdateScore(score)
        }
    }
    
    weak var delegate: GameDelegate?
    
    init(boardSize: BoardSize) {
        self.board = Board(size: boardSize)
        self.board.delegate = self
    }
    
    deinit {
        stopInsertingCircles()
    }
    
    func start() {
        startInsertingCircles()
    }
    
    func pause() {
        stopInsertingCircles()
    }
    
    var isPaused: Bool {
        return !isInsertingCircles
    }
    
    func restart() {
        pause()
        reset()
        start()
    }
    
    func reset() {
        removeAllCircles()
        resetScore()
        difficultyLevel.reset()
    }
    
    func moveCircle(fromLocation from: SlotLocation, toLocation: SlotLocation) throws {
        try board.moveCircle(fromLocation: from, toLocation: toLocation)
        increaseScore()
        difficultyLevel.enableTimeIntervalChanged()
    }
    
    func canMoveCircle(fromLocation from: SlotLocation, toLocation: SlotLocation) -> Bool {
        return board.canMoveCircle(fromLocation: from, toLocation: toLocation)
    }
    
    // MARK: Score
    
    var scoreNumber: Int {
        return score
    }
    
    private func resetScore() {
        score = 0
    }
    
    private func increaseScore() {
        score += difficultyLevel.calculatedSingleActionPoints
    }
    
    // MARK: Inserting Circles
    
    private var insertingTimer: Timer?
    
    var timeInterval: NSTimeInterval {
        return difficultyLevel.calculatedIntervalTime(score)
    }
    
    private var isInsertingCircles: Bool {
        return insertingTimer != nil
    }
    
    private func startInsertingCircles() {
        if let _ = insertingTimer {
            stopInsertingCircles()
        }
        insertingTimer = Timer(interval: timeInterval) { [weak self] in
            self?.insertingTimer?.interval = self?.timeInterval
            self?.insertRandomCircle()
        }
    }
    
    private func stopInsertingCircles() {
        guard let timer = insertingTimer else { return }
        timer.invalidate()
        insertingTimer = nil
    }
    
    private func insertRandomCircle() {
        guard let randomEmptySlot = board.slots.emptySlots.random else { return }
        guard let randomCircleType = CircleType.allTypes.random else { return }
        randomEmptySlot.circle = Circle(type: randomCircleType)
    }
    
    // MARK: Removing Circles
    
    private func removeAllCircles() {
        for slot in board.slots.nonEmptySlots {
            slot.circle = nil
        }
    }
    
}
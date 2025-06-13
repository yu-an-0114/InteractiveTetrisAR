//
//  FingersOverlay.swift
//  InteractiveTetrisAR
//
//  Created by [Your Name] on [Date].
//

import SwiftUI
import Vision

struct FingersOverlay: Shape {
    let points: [CGPoint]
    func path(in rect: CGRect) -> Path {
        var path = Path()
        for pt in points {
            path.addEllipse(in: CGRect(x: pt.x * rect.width - 4, y: pt.y * rect.height - 4, width: 8, height: 8))
        }
        return path
    }
}
struct HandOverlay: Shape {
    let joints: [VNHumanHandPoseObservation.JointName: CGPoint]

    let connections: [[VNHumanHandPoseObservation.JointName]] = [
        // Palm center connections
        [.wrist, .thumbCMC, .thumbMP, .thumbIP, .thumbTip],
        [.wrist, .indexMCP, .indexPIP, .indexDIP, .indexTip],
        [.wrist, .middleMCP, .middlePIP, .middleDIP, .middleTip],
        [.wrist, .ringMCP, .ringPIP, .ringDIP, .ringTip],
        [.wrist, .littleMCP, .littlePIP, .littleDIP, .littleTip]
    ]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Draw connections
        for line in connections {
            for i in 0..<line.count - 1 {
                if let p1 = joints[line[i]], let p2 = joints[line[i + 1]] {
                    path.move(to: CGPoint(x: p1.x * rect.width, y: (1 - p1.y) * rect.height))
                    path.addLine(to: CGPoint(x: p2.x * rect.width, y: (1 - p2.y) * rect.height))
                }
            }
        }

        // Draw joints as circles
        for (_, pt) in joints {
            let x = pt.x * rect.width
            let y = (1 - pt.y) * rect.height
            path.addEllipse(in: CGRect(x: x - 3, y: y - 3, width: 6, height: 6))
        }

        return path
    }
}

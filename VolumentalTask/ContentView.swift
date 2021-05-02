//
//  ContentView.swift
//  VolumentalTask
//
//  Created by Samuel Norling on 2021-04-28.
//

import SwiftUI
import RealityKit
import ARKit
import Combine

struct ContentView : View {
    @Binding var showARView: Bool
    @State var modelIsLocked: Bool = false
    var body: some View {
        ZStack {
            ARViewContainer(
                isModelLocked: $modelIsLocked,
                showARView: $showARView
            )
            .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading){
                HStack(alignment: .top) {
                    Button(action: {
                        withAnimation(.spring()){
                            self.modelIsLocked = false
                            self.showARView = false
                        }
                    }, label: {
                        HStack {
                            Image(systemName:"return")
                            Text("Return")
                        }
                    })
                    .padding()
                    .background(Color.secondary)
                    .foregroundColor(Color.primary)
                    .cornerRadius(20)
                    Spacer()
                }
                Spacer()
            }
            VStack {
                Spacer()
                Button(action: {
                    self.modelIsLocked = !self.modelIsLocked
                }, label: {
                    HStack {
                        if self.modelIsLocked {
                            Image(systemName: "lock")
                            Text("Locked Model")
                        } else {
                            Image(systemName: "lock.open")
                            Text("Unlocked Model")
                        }
                    }
                    .padding()
                    .background(Color.secondary)
                    .foregroundColor(Color.primary)
                    .cornerRadius(20)
                    .animation(.spring())
                })
            }
        }
        
    }
}



struct ARViewContainer: UIViewRepresentable {
    
    @State var sceneWatcher: SceneWatcher?
    
    @Binding var isModelLocked: Bool
    
    @Binding var showARView: Bool
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        self.resetARView(arView: arView)
        arView.addCoaching()
        DispatchQueue.main.async {
            self.sceneWatcher = SceneWatcher(arView: arView, isModelLocked: $isModelLocked)
        }
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if showARView == false {
            self.resetARView(arView: uiView)
        }
    }
    
    func resetARView(arView: ARView){
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
    
    class SceneWatcher {
        var isModelLocked: Binding<Bool>
        var sceneSubscription: Cancellable?
        var arView: ARView
        var footEntity: ModelEntity?
        var modelSubscription: Cancellable?
        var footInitiated: Bool = false
        var updateBlock = false
        var repeatRaycast: ARTrackedRaycast?
        init(arView: ARView, isModelLocked: Binding<Bool>) {
            self.arView = arView
            self.isModelLocked = isModelLocked
            self.modelSubscription = Entity.loadModelAsync(named: "left")   // From the app's main bundle.
                .sink(receiveCompletion: { loadCompletion in
                    print("loadModelAsync subscription complete")
                }, receiveValue: { entity in
                    // Do something with `entity`.
                    print("loaded left.usdz successfully")
                    self.footEntity = entity
                    
                })
            
            self.sceneSubscription = self.arView.scene.subscribe(to: SceneEvents.Update.self) { (event) in
                if isModelLocked.wrappedValue || self.updateBlock {
                    //print("Model is locked or updateBlock is true.")
                    return
                }
                self.updateBlock = true
                let waitUpdateTime: TimeInterval = 2
                DispatchQueue.main.asyncAfter(deadline: .now() + waitUpdateTime, execute: {
                    self.updateBlock = false
                })
                
                guard let query: ARRaycastQuery = arView.makeRaycastQuery(from: arView.center, allowing: .existingPlaneGeometry, alignment: .horizontal) else { return }
                self.repeatRaycast = self.arView.session.trackedRaycast(query) { results in
                    guard let result: ARRaycastResult = results.first, let entity = self.footEntity
                    else { return }

                    let anchor = AnchorEntity(world: result.worldTransform)
                    self.arView.scene.anchors.first?.removeFromParent()
                    anchor.addChild(entity)
                    self.arView.scene.anchors.append(anchor)
                }
                return
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    @State static var showARView = false
    static var previews: some View {
        ContentView(showARView: $showARView)
    }
}
#endif

extension ARView: ARCoachingOverlayViewDelegate {
    func addCoaching() {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.delegate = self
        coachingOverlay.session = self.session
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(coachingOverlay)
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.activatesAutomatically = true
        coachingOverlay.setActive(true, animated: true)
    }
    
    public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        print("coachingOverlayViewDidDeactivate")
    }
}


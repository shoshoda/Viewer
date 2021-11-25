using System;
using System.Diagnostics;
using System.Collections;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Runtime.InteropServices;

// Using windows runtime APIs
#if ENABLE_WINMD_SUPPORT
using Windows.UI.Xaml;
using Windows.Graphics.Imaging;
using Windows.Perception.Spatial;

// Include winrt components
using HoloLensForCV;
#endif

using UnityEngine;
using UnityEngine.UI;
using UnityEngine.XR.WSA;
using UnityEngine.XR.WSA.Input;
using System.Threading;
using Microsoft.MixedReality.Toolkit.Experimental.Utilities;

using TMPro;

// App permissions, modify the appx file for research mode streams
// https://docs.microsoft.com/en-us/windows/uwp/packaging/app-capability-declarations

// Reimplement as list loop structure... 
namespace ArUcoDetectionHoloLensUnity
{
    // Using the hololens for cv .winmd file for runtime support
    // Build HoloLensForCV c++ project (ARM) and copy all output files
    // to Assets->Plugins->ARM
    // https://docs.unity3d.com/2018.4/Documentation/Manual/IL2CPP-WindowsRuntimeSupport.html
    public class ArUcoMarkerDetection : MonoBehaviour
    {
        private bool _isWorldAnchored = false;

        public Text myText;
        public Text pos1, pos2, pos3;


        // Position envoyé pour les calculs
        [HideInInspector]
        public Vector3 position1_temp, position2_temp, position3_temp, position4_temp, position5_temp, position6_temp, position7_temp, position8_temp, position9_temp, position10_temp, position11_temp, position12_temp;
        [HideInInspector]
        public Quaternion rotation1_temp, rotation2_temp, rotation3_temp, rotation4_temp, rotation5_temp, rotation6_temp, rotation7_temp, rotation8_temp, rotation9_temp, rotation10_temp, rotation11_temp, rotation12_temp;

        [HideInInspector]
        public double radius = 0.025; // Distance entre les markers et le centre du dodécaèdre
        [HideInInspector]
        public double tc = 25 / 3;


        public CvUtils.DeviceTypeUnity deviceType;

        // Note: HL2 only has PV camera function currently.
        public CvUtils.SensorTypeUnity sensorTypePv;
        public CvUtils.ArUcoDictionaryName arUcoDictionaryName;

        // Params for aruco detection
        // Marker size in meters: 0.02 m (2cm)
        public float markerSize;
        public float centerSize;

        /// <summary>
        /// Holder for the camera parameters (intrinsics and extrinsics)
        /// of the tracking sensor on the HoloLens 2
        /// </summary>
        public CameraCalibrationParams calibParams;


        /// <summary>
        /// Game object to use for marker instantiation. These game objects are the cubes associated with the respective arUco codes.
        /// </summary>
        public GameObject markerWrist;
        public GameObject markerElbow;
        public GameObject markerShoulder;
        public GameObject marker_4;
        public GameObject marker_5;
        public GameObject marker_6;
        public GameObject marker_7;
        public GameObject marker_8;
        public GameObject marker_9;
        public GameObject marker_10;
        public GameObject marker_11;
        public GameObject marker_12;
        public GameObject center_dode;



        /// <summary>
        /// List of prefab instances of detected aruco markers. Currently not using this code.
        /// </summary>
        //private List<GameObject> _markerGOs; - might need to do this instead for the private list of game objects instead of having 3 public 
        /// game object variables.

        private bool _mediaFrameSourceGroupsStarted = false;
        private int _frameCount = 0;
        public int skipFrames = 1; // previously 3, however, this slowed down the tracking.
        // Set the marker ArUco IDs for each joint - ensure the markers are strapped to the limb in the correct way.
        private int MarkerIDWrist = 0;
        private int MarkerIDElbow = 1;
        private int MarkerIDShoulder = 2;
        // Ajout pour le dodecaedron
        [HideInInspector]
        public int Marker4_ID = 3;
        [HideInInspector]
        public int Marker5_ID = 4;
        [HideInInspector]
        public int Marker6_ID = 5;
        [HideInInspector]
        public int Marker7_ID = 6;
        [HideInInspector]
        public int Marker8_ID = 7;
        [HideInInspector]
        public int Marker9_ID = 8;
        [HideInInspector]
        public int Marker10_ID = 9;
        [HideInInspector]
        public int Marker11_ID = 10;
        [HideInInspector]
        public int Marker12_ID = 11;




        // Used to display the text for joints, angle and angular velocity in the UI of Holo in real time.
        public TextMeshProUGUI MarkerTextWrist;
        public TextMeshProUGUI MarkerTextElbow;
        public TextMeshProUGUI MarkerTextShoulder;
        public TextMeshPro pos1_text, pos2_text, pos3_text;


#if ENABLE_WINMD_SUPPORT
        // Enable winmd support to include winmd files. Will not
        // run in Unity editor.
        private SensorFrameStreamer _sensorFrameStreamerPv;
        private SpatialPerception _spatialPerception;
        private HoloLensForCV.DeviceType _deviceType;
        private MediaFrameSourceGroupType _mediaFrameSourceGroup;

        /// <summary>
        /// Media frame source groups for each sensor stream.
        /// </summary>
        private MediaFrameSourceGroup _pvMediaFrameSourceGroup;
        private SensorType _sensorType;

        /// <summary>
        /// ArUco marker tracker winRT class
        /// </summary>
        //private ArUcoMarkerTracker _arUcoMarkerTracker;

        /// <summary>
        /// Coordinate system reference for Unity to WinRt 
        /// transform construction
        /// </summary>
        private SpatialCoordinateSystem _unityCoordinateSystem;
#endif

        // Gesture handler - this is used to allow the termination of stream recording at the end of APP use using 
        // the double click gesture
        GestureRecognizer _gestureRecognizer;

        #region UnityMethods

        // Use this for initialization
        async void Start()
        {
            // Initialize gesture handler
            InitializeHandler();

            // Start the media frame source groups.
            await StartHoloLensMediaFrameSourceGroups();

            // Wait for a few seconds prior to making calls to Update 
            // HoloLens media frame source groups.
            StartCoroutine(DelayCoroutine());


            markerWrist.transform.localScale = new Vector3(markerSize, markerSize, markerSize);
            markerElbow.transform.localScale = new Vector3(markerSize, markerSize, markerSize);
            markerShoulder.transform.localScale = new Vector3(markerSize, markerSize, markerSize);
            marker_4.transform.localScale = new Vector3(markerSize, markerSize, markerSize);
            marker_5.transform.localScale = new Vector3(markerSize, markerSize, markerSize);
            marker_6.transform.localScale = new Vector3(markerSize, markerSize, markerSize);
            marker_7.transform.localScale = new Vector3(markerSize, markerSize, markerSize);
            marker_8.transform.localScale = new Vector3(markerSize, markerSize, markerSize);
            marker_9.transform.localScale = new Vector3(markerSize, markerSize, markerSize);
            marker_10.transform.localScale = new Vector3(markerSize, markerSize, markerSize);
            marker_11.transform.localScale = new Vector3(markerSize, markerSize, markerSize);
            marker_12.transform.localScale = new Vector3(markerSize, markerSize, markerSize);
            center_dode.transform.localScale = new Vector3(centerSize, centerSize, centerSize);
        }

        /// <summary>
        /// https://docs.unity3d.com/ScriptReference/WaitForSeconds.html
        /// Wait for some seconds for media frame source groups to complete
        /// their initialization.
        /// </summary>
        /// <returns></returns>
        IEnumerator DelayCoroutine()
        {
            UnityEngine.Debug.Log("Started Coroutine at timestamp : " + Time.time);

            // YieldInstruction that waits for 2 seconds.
            yield return new WaitForSeconds(2);

            UnityEngine.Debug.Log("Finished Coroutine at timestamp : " + Time.time);
        }

        // Update is called once per frame
        async void Update()
        {
#if ENABLE_WINMD_SUPPORT
            _frameCount += 1;

            // Predict every frame - used to be third
            if (_frameCount == skipFrames)
            {
                // Potentially this is where I will need to look for 3 ArUco markers instead of just the one. Var declares local 
                // variables without giving them explicit types.
                // wait until the task is completed => task being completed - using the type of sensor stream detect
                // the markers with openCV

                
                var detections = await Task.Run(() => _pvMediaFrameSourceGroup.DetectArUcoMarkers(_sensorType));
                
                // Update the game object pose with current detections - this will have to be 3 seperate game objects/ their poses.
                UpdateArUcoDetections(detections);
                
                _frameCount = 0;
            }
#endif
        }

        async void OnApplicationQuit()
        {
            await StopHoloLensMediaFrameSourceGroup();
        }

        #endregion

        async Task StartHoloLensMediaFrameSourceGroups()
        {
#if ENABLE_WINMD_SUPPORT
            // VAriables not used anymore:
            //rotationLastWrist = transform.rotation;
            //rotationLastShoulder = transform.rotation.eulerAngles;

            // Plugin doesn't work in the Unity editor
            myText.text = "Initializing MediaFrameSourceGroups...";

            // PV
            UnityEngine.Debug.Log("HoloLensForCVUnity.ArUcoDetection.StartHoloLensMediaFrameSourceGroup: Setting up sensor frame streamer");
            _sensorType = (SensorType)sensorTypePv;
            _sensorFrameStreamerPv = new SensorFrameStreamer();
            _sensorFrameStreamerPv.Enable(_sensorType);

            // Spatial perception
            UnityEngine.Debug.Log("HoloLensForCVUnity.ArUcoDetection.StartHoloLensMediaFrameSourceGroup: Setting up spatial perception");
            _spatialPerception = new SpatialPerception();

            // Enable media frame source groups
            // PV
            UnityEngine.Debug.Log("HoloLensForCVUnity.ArUcoDetection.StartHoloLensMediaFrameSourceGroup: Setting up the media frame source group");

            // Check if using research mode sensors
            if (sensorTypePv == CvUtils.SensorTypeUnity.PhotoVideo)
                _mediaFrameSourceGroup = MediaFrameSourceGroupType.PhotoVideoCamera;
            else
                _mediaFrameSourceGroup = MediaFrameSourceGroupType.HoloLensResearchModeSensors;

            // Cast device type 
            _deviceType = (HoloLensForCV.DeviceType)deviceType;
            _pvMediaFrameSourceGroup = new MediaFrameSourceGroup(
                _mediaFrameSourceGroup,
                _spatialPerception,
                _deviceType,
                _sensorFrameStreamerPv,

                // Calibration parameters from opencv, compute once for each hololens 2 device - haven't changed.
                calibParams.focalLength.x, calibParams.focalLength.y,
                calibParams.principalPoint.x, calibParams.principalPoint.y,
                calibParams.radialDistortion.x, calibParams.radialDistortion.y, calibParams.radialDistortion.z,
                calibParams.tangentialDistortion.x, calibParams.tangentialDistortion.y,
                calibParams.imageHeight, calibParams.imageWidth);
            _pvMediaFrameSourceGroup.Enable(_sensorType);

            // Start media frame source groups
            myText.text = "Starting MediaFrameSourceGroups...";

            // Photo video
            UnityEngine.Debug.Log("HoloLensForCVUnity.ArUcoDetection.StartHoloLensMediaFrameSourceGroup: Starting the media frame source group");
            await _pvMediaFrameSourceGroup.StartAsync();
            _mediaFrameSourceGroupsStarted = true;

            myText.text = "MediaFrameSourceGroups started...";

            // Initialize the Unity coordinate system
            // Get pointer to Unity's spatial coordinate system
            // https://github.com/qian256/HoloLensARToolKit/blob/master/ARToolKitUWP-Unity/Scripts/ARUWPVideo.cs
            try
            {
                _unityCoordinateSystem = Marshal.GetObjectForIUnknown(WorldManager.GetNativeISpatialCoordinateSystemPtr()) as SpatialCoordinateSystem;
            }
            catch (Exception)
            {
                UnityEngine.Debug.Log("ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection: Could not get pointer to Unity spatial coordinate system.");
                throw;
            }

            // Initialize the aruco marker detector with parameters
            await _pvMediaFrameSourceGroup.StartArUcoMarkerTrackerAsync(
                markerSize, 
                (int)arUcoDictionaryName, 
                _unityCoordinateSystem);
#endif
        }

        // Get the latest frame from hololens media
        // frame source group -- not needed; I didnt add in this comment
#if ENABLE_WINMD_SUPPORT           
        void UpdateArUcoDetections(IList<DetectedArUcoMarker> detections)
        {

            if (!_mediaFrameSourceGroupsStarted ||
                _pvMediaFrameSourceGroup == null)
            {
                return;
            }


            // IList<DetectedArUcoMarker> detectedArUcoMarkers = _pvMediaFrameSourceGroup.GetArUcoDetections();
            // _pvMediaFrameSourceGroup.DetectArUcoMarkers(_sensorType);
          
            // wait until all 3 markers are detected.
            if (detections.Count != 0)
            {
                
                // Remove world anchor from game object
                if (_isWorldAnchored)
                {
                    try
                    {
                        DestroyImmediate(markerWrist.GetComponent<WorldAnchor>());
                        DestroyImmediate(markerElbow.GetComponent<WorldAnchor>());
                        DestroyImmediate(markerShoulder.GetComponent<WorldAnchor>());
                        DestroyImmediate(marker_4.GetComponent<WorldAnchor>());
                        DestroyImmediate(marker_5.GetComponent<WorldAnchor>());
                        DestroyImmediate(marker_6.GetComponent<WorldAnchor>());
                        DestroyImmediate(marker_7.GetComponent<WorldAnchor>());
                        DestroyImmediate(marker_8.GetComponent<WorldAnchor>());
                        DestroyImmediate(marker_9.GetComponent<WorldAnchor>());
                        DestroyImmediate(marker_10.GetComponent<WorldAnchor>());
                        DestroyImmediate(marker_11.GetComponent<WorldAnchor>());
                        DestroyImmediate(marker_12.GetComponent<WorldAnchor>());
                        DestroyImmediate(center_dode.GetComponent<WorldAnchor>());

                        _isWorldAnchored = false;
                    }
                    catch (Exception)
                    {
                        throw;
                    }
                }




                //// HARDCODED to try and track all 3 ArUco markers instead of 1. THis is effectively the same as a for loop with 
                /// naming being slightly easier for now - will change.
                // Get pose from OpenCV and format for Unity

                // This code works - been altered to only assign in this order on first detection of ArUco codes


                foreach (var index in detections)
                {
                    // if statements used to match each ID to the respective joints (codes).
                    if (index.Id == MarkerIDWrist)
                    {
                        markerWrist.SetActive(true);
                        center_dode.SetActive(true);
                        Vector3 position1 = CvUtils.Vec3FromFloat3(index.Position);
                        position1.y *= -1f;


                        Quaternion rotation1 = CvUtils.RotationQuatFromRodrigues(CvUtils.Vec3FromFloat3(index.Rotation));
                        Matrix4x4 cameraToWorldUnity1 = CvUtils.Mat4x4FromFloat4x4(index.CameraToWorldUnity);
                        Matrix4x4 transformUnityCamera1 = CvUtils.TransformInUnitySpace(position1, rotation1);

                        // Use camera to world transform to get world pose of marker
                        Matrix4x4 transformUnityWorld1 = cameraToWorldUnity1 * transformUnityCamera1;

                        // Apply updated transform to gameobject in world
                        markerWrist.transform.SetPositionAndRotation(
                            CvUtils.GetVectorFromMatrix(transformUnityWorld1),
                            CvUtils.GetQuatFromMatrix(transformUnityWorld1));

                        center_dode.transform.SetPositionAndRotation(
                            CvUtils.GetVectorFromMatrix(transformUnityWorld1),
                            CvUtils.GetQuatFromMatrix(transformUnityWorld1));

                        // Added this in to print the position instead of the ID
                        //MarkerTextWrist.SetText(markerWrist.transform.position.ToString());
                        //MarkerTextWrist.SetText("Wrist");

                        //Position et rotation envoyé pour les déplacements de la machoire
                        position1_temp = position1;
                        rotation1_temp = rotation1;
                        pos1_text.text = index.ToString();
                        myText.text = index.ToString();

                    }
                    
                    else if (index.Id == MarkerIDElbow)
                    {
                        markerElbow.SetActive(true);
                        Vector3 position2 = CvUtils.Vec3FromFloat3(index.Position);
                        position2.y *= -1f;

                        Quaternion rotation2 = CvUtils.RotationQuatFromRodrigues(CvUtils.Vec3FromFloat3(index.Rotation));
                        Matrix4x4 cameraToWorldUnity2 = CvUtils.Mat4x4FromFloat4x4(index.CameraToWorldUnity);
                        Matrix4x4 transformUnityCamera2 = CvUtils.TransformInUnitySpace(position2, rotation2);

                        // Use camera to world transform to get world pose of marker
                        Matrix4x4 transformUnityWorld2 = cameraToWorldUnity2 * transformUnityCamera2;

                        // Apply updated transform to gameobject in world
                        markerElbow.transform.SetPositionAndRotation(
                            CvUtils.GetVectorFromMatrix(transformUnityWorld2),
                            CvUtils.GetQuatFromMatrix(transformUnityWorld2));

                        // Added this in to print the position instead of the ID
                        //MarkerTextWrist.SetText(markerWrist.transform.position.ToString());
                       // MarkerTextElbow.SetText("Elbow");

                      //Position et rotation envoyé pour les déplacements de la machoire
                        position2_temp = position2;
                        rotation2_temp = rotation2;
                    }
                    // this will detect any remaining code in the field of view - if this is a problem then change to else if.
                    else if(index.Id == MarkerIDShoulder)
                    {
                        markerShoulder.SetActive(true);
                        Vector3 position3 = CvUtils.Vec3FromFloat3(index.Position);
                        position3.y *= -1f;

                        Quaternion rotation3 = CvUtils.RotationQuatFromRodrigues(CvUtils.Vec3FromFloat3(index.Rotation));
                        Matrix4x4 cameraToWorldUnity3 = CvUtils.Mat4x4FromFloat4x4(index.CameraToWorldUnity);
                        Matrix4x4 transformUnityCamera3 = CvUtils.TransformInUnitySpace(position3, rotation3);

                        // Use camera to world transform to get world pose of marker
                        Matrix4x4 transformUnityWorld3 = cameraToWorldUnity3 * transformUnityCamera3;

                        // Apply updated transform to gameobject in world
                        markerShoulder.transform.SetPositionAndRotation(
                            CvUtils.GetVectorFromMatrix(transformUnityWorld3),
                            CvUtils.GetQuatFromMatrix(transformUnityWorld3));

                        // Added this in to print the position instead of the ID
                         //MarkerTextWrist.SetText(markerWrist.transform.position.ToString());
                        // MarkerTextShoulder.SetText("Shoulder");
                      //Position et rotation envoyé pour les déplacements de la machoire
                        position3_temp = position3;
                        rotation3_temp = rotation3;
                    }
                    else if(index.Id == Marker4_ID)
                    {
                        marker_4.SetActive(true);
                        Vector3 position4 = CvUtils.Vec3FromFloat3(index.Position);
                        position4.y *= -1f;

                        Quaternion rotation4 = CvUtils.RotationQuatFromRodrigues(CvUtils.Vec3FromFloat3(index.Rotation));
                        Matrix4x4 cameraToWorldUnity4 = CvUtils.Mat4x4FromFloat4x4(index.CameraToWorldUnity);
                        Matrix4x4 transformUnityCamera4 = CvUtils.TransformInUnitySpace(position4, rotation4);

                        // Use camera to world transform to get world pose of marker
                        Matrix4x4 transformUnityWorld4 = cameraToWorldUnity4 * transformUnityCamera4;

                        // Apply updated transform to gameobject in world
                        marker_4.transform.SetPositionAndRotation(
                            CvUtils.GetVectorFromMatrix(transformUnityWorld4),
                            CvUtils.GetQuatFromMatrix(transformUnityWorld4));

                        // Added this in to print the position instead of the ID
                         //MarkerTextWrist.SetText(markerWrist.transform.position.ToString());
                        // MarkerTextShoulder.SetText("Shoulder");
                      //Position et rotation envoyé pour les déplacements de la machoire
                        position4_temp = position4;
                        rotation4_temp = rotation4;
                    }
                    else if(index.Id == Marker5_ID)
                    {
                        marker_5.SetActive(true);
                        Vector3 position5 = CvUtils.Vec3FromFloat3(index.Position);
                        position5.y *= -1f;

                        Quaternion rotation5 = CvUtils.RotationQuatFromRodrigues(CvUtils.Vec3FromFloat3(index.Rotation));
                        Matrix4x4 cameraToWorldUnity5 = CvUtils.Mat4x4FromFloat4x4(index.CameraToWorldUnity);
                        Matrix4x4 transformUnityCamera5 = CvUtils.TransformInUnitySpace(position5, rotation5);

                        // Use camera to world transform to get world pose of marker
                        Matrix4x4 transformUnityWorld5 = cameraToWorldUnity5 * transformUnityCamera5;

                        // Apply updated transform to gameobject in world
                        marker_5.transform.SetPositionAndRotation(
                            CvUtils.GetVectorFromMatrix(transformUnityWorld5),
                            CvUtils.GetQuatFromMatrix(transformUnityWorld5));

                        // Added this in to print the position instead of the ID
                         //MarkerTextWrist.SetText(markerWrist.transform.position.ToString());
                        // MarkerTextShoulder.SetText("Shoulder");
                        //Position et rotation envoyé pour les déplacements de la machoire
                        position5_temp = position5;
                        rotation5_temp = rotation5;

                    }
                    else if(index.Id == Marker6_ID)
                    {
                        marker_6.SetActive(true);
                        Vector3 position6 = CvUtils.Vec3FromFloat3(index.Position);
                        position6.y *= -1f;

                        Quaternion rotation6 = CvUtils.RotationQuatFromRodrigues(CvUtils.Vec3FromFloat3(index.Rotation));
                        Matrix4x4 cameraToWorldUnity6 = CvUtils.Mat4x4FromFloat4x4(index.CameraToWorldUnity);
                        Matrix4x4 transformUnityCamera6 = CvUtils.TransformInUnitySpace(position6, rotation6);

                        // Use camera to world transform to get world pose of marker
                        Matrix4x4 transformUnityWorld6 = cameraToWorldUnity6 * transformUnityCamera6;

                        // Apply updated transform to gameobject in world
                        marker_6.transform.SetPositionAndRotation(
                            CvUtils.GetVectorFromMatrix(transformUnityWorld6),
                            CvUtils.GetQuatFromMatrix(transformUnityWorld6));

                        // Added this in to print the position instead of the ID
                         //MarkerTextWrist.SetText(markerWrist.transform.position.ToString());
                        // MarkerTextShoulder.SetText("Shoulder");
                        //Position et rotation envoyé pour les déplacements de la machoire
                        position6_temp = position6;
                        rotation6_temp = rotation6;

                    }
                    else if(index.Id == Marker7_ID)
                    {
                        marker_7.SetActive(true);
                        Vector3 position7 = CvUtils.Vec3FromFloat3(index.Position);
                        position7.y *= -1f;

                        Quaternion rotation7 = CvUtils.RotationQuatFromRodrigues(CvUtils.Vec3FromFloat3(index.Rotation));
                        Matrix4x4 cameraToWorldUnity7 = CvUtils.Mat4x4FromFloat4x4(index.CameraToWorldUnity);
                        Matrix4x4 transformUnityCamera7 = CvUtils.TransformInUnitySpace(position7, rotation7);

                        // Use camera to world transform to get world pose of marker
                        Matrix4x4 transformUnityWorld7 = cameraToWorldUnity7 * transformUnityCamera7;

                        // Apply updated transform to gameobject in world
                        marker_7.transform.SetPositionAndRotation(
                            CvUtils.GetVectorFromMatrix(transformUnityWorld7),
                            CvUtils.GetQuatFromMatrix(transformUnityWorld7));

                        // Added this in to print the position instead of the ID
                         //MarkerTextWrist.SetText(markerWrist.transform.position.ToString());
                        // MarkerTextShoulder.SetText("Shoulder");
                        //Position et rotation envoyé pour les déplacements de la machoire
                        position7_temp = position7;
                        rotation7_temp = rotation7;

                    }
                    else if(index.Id == Marker8_ID)
                    {
                        marker_8.SetActive(true);
                        Vector3 position8 = CvUtils.Vec3FromFloat3(index.Position);
                        position8.y *= -1f;

                        Quaternion rotation8 = CvUtils.RotationQuatFromRodrigues(CvUtils.Vec3FromFloat3(index.Rotation));
                        Matrix4x4 cameraToWorldUnity8 = CvUtils.Mat4x4FromFloat4x4(index.CameraToWorldUnity);
                        Matrix4x4 transformUnityCamera8 = CvUtils.TransformInUnitySpace(position8, rotation8);

                        // Use camera to world transform to get world pose of marker
                        Matrix4x4 transformUnityWorld8 = cameraToWorldUnity8 * transformUnityCamera8;

                        // Apply updated transform to gameobject in world
                        marker_8.transform.SetPositionAndRotation(
                            CvUtils.GetVectorFromMatrix(transformUnityWorld8),
                            CvUtils.GetQuatFromMatrix(transformUnityWorld8));

                        // Added this in to print the position instead of the ID
                         //MarkerTextWrist.SetText(markerWrist.transform.position.ToString());
                        // MarkerTextShoulder.SetText("Shoulder");
                        //Position et rotation envoyé pour les déplacements de la machoire
                        position8_temp = position8;
                        rotation8_temp = rotation8;

                    }
                    else if(index.Id == Marker9_ID)
                    {
                        marker_9.SetActive(true);
                        Vector3 position9 = CvUtils.Vec3FromFloat3(index.Position);
                        position9.y *= -1f;

                        Quaternion rotation9 = CvUtils.RotationQuatFromRodrigues(CvUtils.Vec3FromFloat3(index.Rotation));
                        Matrix4x4 cameraToWorldUnity9 = CvUtils.Mat4x4FromFloat4x4(index.CameraToWorldUnity);
                        Matrix4x4 transformUnityCamera9 = CvUtils.TransformInUnitySpace(position9, rotation9);

                        // Use camera to world transform to get world pose of marker
                        Matrix4x4 transformUnityWorld9 = cameraToWorldUnity9 * transformUnityCamera9;

                        // Apply updated transform to gameobject in world
                        marker_9.transform.SetPositionAndRotation(
                            CvUtils.GetVectorFromMatrix(transformUnityWorld9),
                            CvUtils.GetQuatFromMatrix(transformUnityWorld9));

                        // Added this in to print the position instead of the ID
                         //MarkerTextWrist.SetText(markerWrist.transform.position.ToString());
                        // MarkerTextShoulder.SetText("Shoulder");
                        //Position et rotation envoyé pour les déplacements de la machoire
                        position9_temp = position9;
                        rotation9_temp = rotation9;

                    }
                    else if(index.Id == Marker10_ID)
                    {
                        marker_10.SetActive(true);
                        Vector3 position10 = CvUtils.Vec3FromFloat3(index.Position);
                        position10.y *= -1f;

                        Quaternion rotation10 = CvUtils.RotationQuatFromRodrigues(CvUtils.Vec3FromFloat3(index.Rotation));
                        Matrix4x4 cameraToWorldUnity10 = CvUtils.Mat4x4FromFloat4x4(index.CameraToWorldUnity);
                        Matrix4x4 transformUnityCamera10 = CvUtils.TransformInUnitySpace(position10, rotation10);

                        // Use camera to world transform to get world pose of marker
                        Matrix4x4 transformUnityWorld10 = cameraToWorldUnity10 * transformUnityCamera10;

                        // Apply updated transform to gameobject in world
                        marker_10.transform.SetPositionAndRotation(
                            CvUtils.GetVectorFromMatrix(transformUnityWorld10),
                            CvUtils.GetQuatFromMatrix(transformUnityWorld10));

                        // Added this in to print the position instead of the ID
                         //MarkerTextWrist.SetText(markerWrist.transform.position.ToString());
                        // MarkerTextShoulder.SetText("Shoulder");
                        //Position et rotation envoyé pour les déplacements de la machoire
                        position10_temp = position10;
                        rotation10_temp = rotation10;

                    }
                    else if(index.Id == Marker11_ID)
                    {
                        marker_11.SetActive(true);
                        Vector3 position11 = CvUtils.Vec3FromFloat3(index.Position);
                        position11.y *= -1f;

                        Quaternion rotation11 = CvUtils.RotationQuatFromRodrigues(CvUtils.Vec3FromFloat3(index.Rotation));
                        Matrix4x4 cameraToWorldUnity11 = CvUtils.Mat4x4FromFloat4x4(index.CameraToWorldUnity);
                        Matrix4x4 transformUnityCamera11 = CvUtils.TransformInUnitySpace(position11, rotation11);

                        // Use camera to world transform to get world pose of marker
                        Matrix4x4 transformUnityWorld11 = cameraToWorldUnity11 * transformUnityCamera11;

                        // Apply updated transform to gameobject in world
                        marker_11.transform.SetPositionAndRotation(
                            CvUtils.GetVectorFromMatrix(transformUnityWorld11),
                            CvUtils.GetQuatFromMatrix(transformUnityWorld11));

                        // Added this in to print the position instead of the ID
                         //MarkerTextWrist.SetText(markerWrist.transform.position.ToString());
                        // MarkerTextShoulder.SetText("Shoulder");
                        //Position et rotation envoyé pour les déplacements de la machoire
                        position11_temp = position11;
                        rotation11_temp = rotation11;

                    }
                    else
                    {
                        marker_12.SetActive(true);
                        Vector3 position12 = CvUtils.Vec3FromFloat3(index.Position);
                        position12.y *= -1f;

                        Quaternion rotation12 = CvUtils.RotationQuatFromRodrigues(CvUtils.Vec3FromFloat3(index.Rotation));
                        Matrix4x4 cameraToWorldUnity12 = CvUtils.Mat4x4FromFloat4x4(index.CameraToWorldUnity);
                        Matrix4x4 transformUnityCamera12 = CvUtils.TransformInUnitySpace(position12, rotation12);

                        // Use camera to world transform to get world pose of marker
                        Matrix4x4 transformUnityWorld12 = cameraToWorldUnity12 * transformUnityCamera12;

                        // Apply updated transform to gameobject in world
                        marker_12.transform.SetPositionAndRotation(
                            CvUtils.GetVectorFromMatrix(transformUnityWorld12),
                            CvUtils.GetQuatFromMatrix(transformUnityWorld12));

                        // Added this in to print the position instead of the ID
                         //MarkerTextWrist.SetText(markerWrist.transform.position.ToString());
                        // MarkerTextShoulder.SetText("Shoulder");
                        //Position et rotation envoyé pour les déplacements de la machoire
                        position12_temp = position12;
                        rotation12_temp = rotation12;
                    }
                }

                // This turns the coordinates into vectors
                Vector3 vec1 = markerWrist.transform.position - markerElbow.transform.position;
                Vector3 vec2 = markerShoulder.transform.position - markerElbow.transform.position;       
                

            }

            else
            {
                // Add a world anchor to the attached gameobject
                _isWorldAnchored = true;
                markerWrist.SetActive(false);
                markerElbow.SetActive(false);
                markerShoulder.SetActive(false);
                marker_4.SetActive(false);
                marker_5.SetActive(false);
                marker_6.SetActive(false);
                marker_7.SetActive(false);
                marker_8.SetActive(false);
                marker_9.SetActive(false);
                marker_10.SetActive(false);
                marker_11.SetActive(false);
                marker_12.SetActive(false);
                center_dode.SetActive(false);

            }

        }
#endif

        /// <summary>
        /// Stop the media frame source groups.
        /// </summary>
        /// <returns></returns>
        async Task StopHoloLensMediaFrameSourceGroup()
        {
#if ENABLE_WINMD_SUPPORT
            if (!_mediaFrameSourceGroupsStarted ||
                _pvMediaFrameSourceGroup == null)
            {
                return;
            }

            // Wait for frame source groups to stop.
            await _pvMediaFrameSourceGroup.StopAsync();
            _pvMediaFrameSourceGroup = null;

            // Set to null value
            _sensorFrameStreamerPv = null;

            // Bool to indicate closing
            _mediaFrameSourceGroupsStarted = false;

            myText.text = "Stopped streaming sensor frames. Okay to exit app.";
#endif
        }

        #region ComImport
        // https://docs.microsoft.com/en-us/windows/uwp/audio-video-camera/imaging
        [ComImport]
        [Guid("5B0D3235-4DBA-4D44-865E-8F1D0E4FD04D")]
        [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
        unsafe interface IMemoryBufferByteAccess
        {
            void GetBuffer(out byte* buffer, out uint capacity);
        }
        #endregion

#if ENABLE_WINMD_SUPPORT
        // Get byte array from software bitmap.
        // https://github.com/qian256/HoloLensARToolKit/blob/master/ARToolKitUWP-Unity/Scripts/ARUWPVideo.cs
        unsafe byte* GetByteArrayFromSoftwareBitmap(SoftwareBitmap sb)
        {
            if (sb == null)
                return null;

            //SoftwareBitmap sbCopy = new SoftwareBitmap(sb.BitmapPixelFormat, sb.PixelWidth, sb.PixelHeight);
            SoftwareBitmap sbCopy = new SoftwareBitmap(sb.BitmapPixelFormat, 640, 480);
            Interlocked.Exchange(ref sbCopy, sb);
            using (var input = sbCopy.LockBuffer(BitmapBufferAccessMode.Read))
            using (var inputReference = input.CreateReference())
            {
                byte* inputBytes;
                uint inputCapacity;
                ((IMemoryBufferByteAccess)inputReference).GetBuffer(out inputBytes, out inputCapacity);
                return inputBytes;
            }
        }
#endif

        #region TapGestureHandler
        private void InitializeHandler()
        {
            // New recognizer class
            _gestureRecognizer = new GestureRecognizer();

            // Set tap as a recognizable gesture
            _gestureRecognizer.SetRecognizableGestures(GestureSettings.DoubleTap);

            // Begin listening for gestures
            _gestureRecognizer.StartCapturingGestures();

            // Capture on gesture events with delegate handler
            _gestureRecognizer.Tapped += GestureRecognizer_Tapped;

            UnityEngine.Debug.Log("Gesture recognizer initialized.");
        }

        // On tapped event, stop all frame source groups
        private void GestureRecognizer_Tapped(TappedEventArgs obj)
        {
            StopHoloLensMediaFrameSourceGroup();
            CloseHandler();
        }

        private void CloseHandler()
        {
            _gestureRecognizer.StopCapturingGestures();
            _gestureRecognizer.Dispose();
        }
        #endregion
    }
}




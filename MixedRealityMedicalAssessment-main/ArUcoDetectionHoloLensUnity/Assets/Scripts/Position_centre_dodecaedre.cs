using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class Position_centre_dodecaedre : MonoBehaviour
{
    public Vector3 pos_marker_1, pos_marker_2, pos_marker_3, pos_marker_4, pos_marker_5, pos_marker_6, pos_marker_7, pos_marker_8, pos_marker_9, pos_marker_10, pos_marker_11, pos_marker_12;
    public Quaternion rot_marker_1, rot_marker_2, rot_marker_3, rot_marker_4, rot_marker_5, rot_marker_6, rot_marker_7, rot_marker_8, rot_marker_9, rot_marker_10, rot_marker_11, rot_marker_12;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        // Obtention des positions pour chaque marker
        pos_marker_1 = GetComponent<ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection>().position1_temp;
        pos_marker_2 = GetComponent<ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection>().position2_temp;
        pos_marker_3 = GetComponent<ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection>().position3_temp;
        pos_marker_4 = GetComponent<ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection>().position4_temp;
        pos_marker_5 = GetComponent<ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection>().position5_temp;
        pos_marker_6 = GetComponent<ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection>().position6_temp;
        pos_marker_7 = GetComponent<ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection>().position7_temp;
        pos_marker_8 = GetComponent<ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection>().position8_temp;
        pos_marker_9 = GetComponent<ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection>().position9_temp;
        pos_marker_10 = GetComponent<ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection>().position10_temp;
        pos_marker_11 = GetComponent<ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection>().position11_temp;
        pos_marker_12 = GetComponent<ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection>().position12_temp;

        // Obtention des rotations pour chaque marker
        rot_marker_1 = GetComponent<ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection>().rotation1_temp;
        rot_marker_2 = GetComponent<ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection>().rotation2_temp;
        rot_marker_3 = GetComponent<ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection>().rotation3_temp;
        rot_marker_4 = GetComponent<ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection>().rotation4_temp;
        rot_marker_5 = GetComponent<ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection>().rotation5_temp;
        rot_marker_6 = GetComponent<ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection>().rotation6_temp;
        rot_marker_7 = GetComponent<ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection>().rotation7_temp;
        rot_marker_8 = GetComponent<ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection>().rotation8_temp;
        rot_marker_9 = GetComponent<ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection>().rotation9_temp;
        rot_marker_10 = GetComponent<ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection>().rotation10_temp;
        rot_marker_11 = GetComponent<ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection>().rotation11_temp;
        rot_marker_12 = GetComponent<ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection>().rotation12_temp;
    }


    void centre_dode()
    {
         
    }



}

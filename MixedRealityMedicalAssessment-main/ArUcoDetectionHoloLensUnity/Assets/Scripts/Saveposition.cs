using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using UnityEngine.UI;
using TMPro;
using ArUcoDetectionHoloLensUnity;

public class Saveposition : MonoBehaviour
{
    //public GameObject GamePose1, GamePose2;
    public Vector3 pos_objet_1, pos_objet_2, pos_objet_3;
    public Quaternion rot_Qr_Machoire, rot_Qr_Arcade, rot_Qr_3;
    public Quaternion rot_save1, rot_save2, rot_save3;
    public GameObject Objet_1, Objet_2, Objet_3;
    [SerializeField]
    public double distance_x, distance_y, distance_z;
    public double dif_rot_x, dif_rot_y, dif_rot_z;
    public Vector3 pos_save1, pos_save2, pos_save3;
    public Button button_save;


    // Start is called before the first frame update
    void Start()
    {
        Button btn = button_save.GetComponent<Button>();
        btn.onClick.AddListener(SaveOnClick);
    }

    // Update is called once per frame
    void Update()
    {
        //pos_objet_1 = Objet_1.GetComponent<Pose>().pos;
        pos_objet_1 = GetComponent<ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection>().position1_temp;

        pos_objet_2 = GetComponent<ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection>().position2_temp;
        pos_objet_3 = GetComponent<ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection>().position3_temp;

        rot_Qr_Machoire = GetComponent<ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection>().rotation1_temp;
        rot_Qr_Arcade = GetComponent<ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection>().rotation2_temp;
        rot_save3 = GetComponent<ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection>().rotation3_temp;
    }


    public void SaveOnClick()
    {
        //Save pos + rot
        pos_save1 = pos_objet_1;
        pos_save2 = pos_objet_2;
        pos_save3 = pos_objet_3;
        rot_save1 = rot_Qr_Machoire;
        rot_save2 = rot_Qr_Arcade;
        rot_save3 = rot_Qr_3;

        //Sauvegarde les distances avec le bouton
        distance_x = (pos_objet_2.x - pos_objet_1.x);
        distance_y = (pos_objet_2.y - pos_objet_1.y);
        distance_z = (pos_objet_2.z - pos_objet_1.z);
        string x = distance_x.ToString();
        string y = distance_y.ToString();
        string z = distance_z.ToString();

        //sauvegarde la diff de rotations avec le bouton
        dif_rot_x = (rot_Qr_Arcade.x - rot_Qr_Machoire.x);
        dif_rot_y = (rot_Qr_Arcade.y - rot_Qr_Machoire.y);
        dif_rot_z = (rot_Qr_Arcade.z - rot_Qr_Machoire.z);
        File.WriteAllText("D:\\Projet_I5\\Save_pos.txt", x + "; " + y + "; " + z);
        Debug.Log("Sauvegarde ok");
        Debug.Log("Distance en x : " + distance_x);
        Debug.Log("Distance en y : " + distance_y);
        Debug.Log("Distance en z : " + distance_z);
    }
}

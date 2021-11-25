using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Correction_axe : MonoBehaviour
{
    public GameObject Qr_Machoire, Qr_Arcade, Axe_Reference;
    public Quaternion rot_Qr_Machoire, rot_Qr_Arcade, rot_Axe_Reference, dif_rot1, dif_rot2;
    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.S))
        {
            rot_Qr_Machoire = Qr_Machoire.GetComponent<Pose>().rot;
            rot_Qr_Arcade = Qr_Arcade.GetComponent<Pose2>().rot2;
            rot_Axe_Reference = Axe_Reference.transform.rotation;
            dif_rot1.x = rot_Axe_Reference.x - rot_Qr_Machoire.x;
            dif_rot1.y = rot_Axe_Reference.y - rot_Qr_Machoire.y;
            dif_rot1.z = rot_Axe_Reference.z - rot_Qr_Machoire.z;
            dif_rot2.x = rot_Axe_Reference.x - rot_Qr_Arcade.x;
            dif_rot2.y = rot_Axe_Reference.y - rot_Qr_Arcade.y;
            dif_rot2.z = rot_Axe_Reference.z - rot_Qr_Arcade.z;
            Debug.Log(rot_Qr_Machoire);
            Debug.Log("Dif rotation qr machoire");
            Debug.Log(dif_rot1);
            Debug.Log("Dif rotation qr arcade");
            Debug.Log(dif_rot2);
        }
    }
}

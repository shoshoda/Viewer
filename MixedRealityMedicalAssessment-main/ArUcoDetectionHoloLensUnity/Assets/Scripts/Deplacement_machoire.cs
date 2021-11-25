using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using UnityEngine.UI;
using TMPro;

public class Deplacement_machoire : MonoBehaviour
{

    public double distance_x, distance_y, distance_z;
    public double deplacement_final_x, deplacement_final_y, deplacement_final_z;
    public double dist_reel_x, dist_reel_y, dist_reel_z;
    public double donnee_patient_x, donnee_patient_y, donnee_patient_z;
    public string x, y, z, rx, ry, rz;
    public Vector3 pos_objet_1, pos_objet_2;
    public Quaternion rot_Qr_Machoire, rot_Qr_Arcade;
    public double dif_rot_x, dif_rot_y, dif_rot_z;
    public double rot_reel_x, rot_reel_y, rot_reel_z;
    public double rot_final_x, rot_final_y, rot_final_z;
    public TextMeshProUGUI t_deplacement_x, t_deplacement_y, t_deplacement_z, t_rot_x, t_rot_y, t_rot_z;
    private double delta_position = 100;
    public double test;


    void Start()
    {
        //recuperation des distances
        distance_x = GetComponent<Saveposition>().distance_x;
        distance_y = GetComponent<Saveposition>().distance_y;
        distance_z = GetComponent<Saveposition>().distance_z;
        distance_x = 1000;

        //recuperation des donnees
        donnee_patient_x = GetComponent<Lecture_donnee>().donnee_x;
        donnee_patient_y = GetComponent<Lecture_donnee>().donnee_y;
        donnee_patient_z = GetComponent<Lecture_donnee>().donnee_z;
        donnee_patient_x = 500;
        donnee_patient_y = 122;
        donnee_patient_z = 21;

        //recuperation des rotations
        dif_rot_x = GetComponent<Saveposition>().dif_rot_x;
        dif_rot_y = GetComponent<Saveposition>().dif_rot_y;
        dif_rot_z = GetComponent<Saveposition>().dif_rot_z;
        
        //Calcul deplacement final 
        deplacement_final_x = distance_x - donnee_patient_x;
        deplacement_final_y = distance_y - donnee_patient_y;
        deplacement_final_z = distance_z - donnee_patient_z;
        test = deplacement_final_x - delta_position;

        //Calcul rotation final
        rot_final_x = dif_rot_x;
        rot_final_y = dif_rot_y;
        rot_final_z = dif_rot_z;

    }

    // Update is called once per frame
    void Update()
    {
        //Recuperation des pos/rot en temps reel
        //pos_objet_1 = GetComponent<Saveposition>().pos_objet_1; // - la valeur de la position 0 pour avoir en petit chiffre demande de matthieu
        //pos_objet_2 = GetComponent<Saveposition>().pos_objet_2;

        pos_objet_1 = GetComponent<Saveposition>().pos_objet_1 - GetComponent<Saveposition>().pos_save1;
        pos_objet_2 = GetComponent<Saveposition>().pos_objet_2 - GetComponent<Saveposition>().pos_save2;

        rot_Qr_Machoire = GetComponent<Saveposition>().rot_Qr_Machoire;
        rot_Qr_Arcade = GetComponent<Saveposition>().rot_Qr_Arcade;

        //Calcul distance
        dist_reel_x = (pos_objet_2.x - pos_objet_1.x) * 1000;
        dist_reel_y = (pos_objet_2.y - pos_objet_1.y) * 1000;
        dist_reel_z = (pos_objet_2.z - pos_objet_1.z) * 1000;
        x = dist_reel_x.ToString("00");
        y = dist_reel_y.ToString("00");
        z = dist_reel_z.ToString("00");
        t_deplacement_x.text = x;
        t_deplacement_y.text = y;
        t_deplacement_z.text = z;
        rot_reel_x = (rot_Qr_Arcade.x - rot_Qr_Machoire.x);
        rot_reel_y = (rot_Qr_Arcade.y - rot_Qr_Machoire.y);
        rot_reel_z = (rot_Qr_Arcade.z - rot_Qr_Machoire.z);
        rx = rot_reel_x.ToString(".00");
        ry = rot_reel_y.ToString(".00");
        rz = rot_reel_z.ToString(".00");
        t_rot_x.text = rx;
        t_rot_y.text = ry;
        t_rot_z.text = rz;
        if (dist_reel_x >= (deplacement_final_x - delta_position) && dist_reel_x <= (deplacement_final_x + delta_position))
        {
            t_deplacement_x.color = Color.green;
        }
        else
        {
            t_deplacement_x.color = Color.red;
        }
        if(dist_reel_y >= (deplacement_final_y - delta_position) && dist_reel_y <= (deplacement_final_y + delta_position))
        {
            t_deplacement_y.color = Color.green;
        }
        else
        {
            t_deplacement_y.color = Color.red;
        }
        if(dist_reel_z >= (deplacement_final_z - delta_position) && dist_reel_z <= (deplacement_final_z - delta_position))
        {
            t_deplacement_z.color = Color.green;
        }
        else
        {
            t_deplacement_z.color = Color.red;
        }

        if (Input.GetKeyDown(KeyCode.A))
        {
            Debug.Log(deplacement_final_x);
            Debug.Log(delta_position);
            Debug.Log(test);
        }

    }
}

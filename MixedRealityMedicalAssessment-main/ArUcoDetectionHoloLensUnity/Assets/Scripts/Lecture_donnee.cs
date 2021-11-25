using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using UnityEngine.UI;
using TMPro;
using System;

public class Lecture_donnee : MonoBehaviour
{
    public string donnee_patient_x, donnee_patient_y, donnee_patient_z;
    public double donnee_x, donnee_y, donnee_z;
    string x, y, z;
    public Button bouton_donnee_patient;
    public GameObject imput_x, imput_y, imput_z;
    public TextMeshProUGUI display_x, display_y, display_z;

    void Start()
    {
        bouton_donnee_patient = bouton_donnee_patient.GetComponent<Button>();
        bouton_donnee_patient.onClick.AddListener(stock_donnee);

    }

    void Update()
    { 
        /*
        if(Input.GetKeyDown(KeyCode.S))
        {
            string text = System.IO.File.ReadAllText(@"D:\\Projet_I5\\Donne_Patient.txt");
            char[] separators = new char[] { ';'};
            lines = text.Split(separators);
            Debug.Log("Donne patient : " + lines[0]);
            Debug.Log("Donne patient : " + lines[1]);
            Debug.Log("Donne patient : " + lines[2]);
            donnee_patient_x = Int32.Parse(lines[0]);
            donnee_patient_y = Int32.Parse(lines[1]);
            donnee_patient_z = Int32.Parse(lines[2]);
            x = donnee_patient_x.ToString();
            y = donnee_patient_y.ToString();
            z = donnee_patient_z.ToString();
        }
        */
    }

    public void stock_donnee()
    {
        //recuperation des donnee des imput field
        donnee_patient_x = imput_x.GetComponent<Text>().text;
        //display_x.text  =  donnee_patient_x;
        donnee_patient_y = imput_y.GetComponent<Text>().text;
        //display_y.text = donnee_patient_y;
        donnee_patient_z = imput_z.GetComponent<Text>().text;

        //parsing des donnees en int
        donnee_x = Int32.Parse(donnee_patient_x);
        donnee_y = Int32.Parse(donnee_patient_y);
        donnee_z = Int32.Parse(donnee_patient_z);
    }
    public void SaveDonneePatient()
    {

    }
}

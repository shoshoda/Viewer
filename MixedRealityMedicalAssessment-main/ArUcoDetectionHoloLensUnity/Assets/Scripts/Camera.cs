using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Camera : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        WebCamTexture webcam = new WebCamTexture();
        Debug.Log(webcam.deviceName);

        Renderer renderer = GetComponent<Renderer>();
        renderer.material.mainTexture = webcam;
        webcam.Play();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}

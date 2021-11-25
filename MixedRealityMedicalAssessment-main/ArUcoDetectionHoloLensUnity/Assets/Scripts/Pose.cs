using UnityEngine;
using System.Collections;

public class Pose : MonoBehaviour {

	public Vector3 pos;
	public Quaternion rot;
	// Use this for initialization
	void Start () {



	}
	
	// Update is called once per frame
	void Update () {
		pos = transform.position;
        rot = transform.rotation;
		//Debug.Log("pos is " + pos);
	
	}
}

using UnityEngine;
using System.Collections;

public class Pose3 : MonoBehaviour
{

	public Vector3 pos3;
	public Quaternion rot3;
	// Use this for initialization
	void Start()
	{



	}

	// Update is called once per frame
	void Update()
	{
		pos3 = transform.position;
		rot3 = transform.rotation;
		//Debug.Log("pos is " + pos);

	}
}

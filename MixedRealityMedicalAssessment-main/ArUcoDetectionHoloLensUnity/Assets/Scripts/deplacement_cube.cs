using UnityEngine;
using System.Collections;

public class deplacement_cube : MonoBehaviour
{
	public float speed = 0.25f; // Vitesse de déplacement de l'objet
	public float slowSpeed = 0.01f; // Vitesse pour ralentir l'objet (Pour éviter de tomber sur 3.2 ou 2.9 dans le cas de l'exemple ci dessus (Forum))
	public float minSpeed = 0.25f; // La vitesse minimum que l'objet ne peut pas dépasser, c'est à dire qu'il ne peut pas aller en dessous pour atteindre -0.1 par exemple. (L'objet partirait en arrière)
	public Vector3 destination;
	private bool canMove = true;

	void Update()
	{
		if (transform.position == destination)
			canMove = false;
		else
			if (speed >= minSpeed)
			speed -= slowSpeed;

		if (canMove)
		{
			if (transform.position.x < destination.x)
				transform.position += new Vector3(speed, 0, 0);
			else if (transform.position.x > destination.x)
				transform.position -= new Vector3(speed, 0, 0);
		}
	}
}
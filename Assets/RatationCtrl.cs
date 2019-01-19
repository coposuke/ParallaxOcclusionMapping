using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class RatationCtrl : MonoBehaviour
{
	/// <summary>
	/// 自動的に方位回転するかどうか
	/// </summary>
	[SerializeField]
	private bool isAuto;

	/// <summary>
	/// オート時の回転スピード
	/// </summary>
	[SerializeField]
	private float autoSpeed;

	/// <summary>
	/// 注視点
	/// </summary>
	[SerializeField]
	private Vector3 viewpoint;

	/// <summary>
	/// 注視点からの距離
	/// </summary>
	[SerializeField]
	private float distance;

	/// <summary>
	/// 高度(チルト)
	/// </summary>
	[SerializeField, Range(-89.0f, 89.0f)]
	private float altitudeAngle;

	/// <summary>
	/// 方位(パン)
	/// </summary>
	[SerializeField]
	private float azimuthAngle;

	/// <summary>
	/// Cached Trasnform
	/// </summary>
	private Transform cachedTransform;

	/// <summary>
	/// Cached Trasnform
	/// </summary>
	private Transform CachedTransform { get { return (null == cachedTransform) ? cachedTransform = transform : cachedTransform; } }

	
	/// <summary>
	/// Unity Event Update
	/// </summary>
	private void Update ()
	{
		if (isAuto)
		{
			azimuthAngle += Time.deltaTime * autoSpeed;
		}

		OnValidate();
	}

	/// <summary>
	/// Unity Event OnValidate
	/// </summary>
	private void OnValidate()
	{
		CachedTransform.localPosition = viewpoint;
		CachedTransform.localRotation = Quaternion.Euler(altitudeAngle, azimuthAngle, 0.0f);
		CachedTransform.Translate(new Vector3(0.0f, 0.0f, -distance));
	}
}

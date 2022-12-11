using UnityEngine;

public class Liquid : MonoBehaviour
{
    [SerializeField] private Material _material;
    private int _propertyId;
    
    private void Start()
    {
        _propertyId = Shader.PropertyToID("_TransformPositionY");
        
    }

    private void Update()
    {
        _material.SetFloat(_propertyId, transform.localPosition.y);
        transform.localPosition = new Vector3(0, (Mathf.Sin((Time.time)) * 2), 0);
    }
}

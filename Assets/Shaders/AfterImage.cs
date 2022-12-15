using UnityEngine;

public class AfterImage : MonoBehaviour
{
    [SerializeField] private Material _material;
    [SerializeField] private float _trailSpeed = 10f;
    private Vector3 _trailPos;
    private int _dirid;

    private void Awake()
    {
        _trailPos = transform.position;
        _dirid = Shader.PropertyToID("_TrailDir");
    }
    private void Update()
    {
        Trail();
        Rotate();
    }

    private void Rotate()
    {
        var tr = transform;
        var angleAxis = Quaternion.AngleAxis(100 * Time.deltaTime, Vector3.forward);
        var pos = tr.position;
        tr.position = angleAxis * pos;
    }

    private void Trail()
    {
        var time = Mathf.Clamp01(Time.deltaTime * _trailSpeed);
        var tr = transform.position;
        _trailPos = Vector3.Lerp(_trailPos, tr, time);
        _material.SetVector(_dirid, transform.InverseTransformDirection(_trailPos - tr));
    }
}

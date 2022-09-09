using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MouseScript : MonoBehaviour
{
    // Start is called before the first frame update
    private string propName = "_MousePosition";
    [SerializeField] private Renderer _renderer;
    private Material mat;
    void Start()
    {
        mat = _renderer.material;
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButton(0))
        {
            // Rayを出す
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit_info = new RaycastHit();
            float max_distance = 100f;
            bool is_hit = Physics.Raycast(ray, out hit_info, max_distance);
            // Rayとオブジェクトが衝突した時の処理をかく
            if (is_hit)
            {
                // 衝突
                Debug.Log(hit_info.point);
                // Shaderに座標を返す
                mat.SetVector(propName, hit_info.point);
            }
            
        }
    }
}

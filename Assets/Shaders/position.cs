using System;
using System.Runtime.InteropServices;
using UnityEngine;
using Random = System.Random;

public class position : MonoBehaviour
{
    public Material material;
    public int count = 30;
    private ComputeBuffer _buffer;
    void Start()
    {
        /// シェーダー側に一度に複数の値を渡すためのバッファがComputeBuffer
        /// 構造体のデータサイズは変数のデータサイズの合計に等しいので、Marshal.Sizeofで算出できる
        _buffer = new ComputeBuffer(count, Marshal.SizeOf(typeof(Vector2)));
        Vector2[] positions = new Vector2[count];
        for (int i = 0; i < count; i++)
        {
            positions[i] = new Vector2(1, 1);
        }
        // バッファに配列を入れて
        _buffer.SetData(positions);
        // バッファをマテリアルに渡す。
        material.SetBuffer("_Buffer", _buffer);
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
       Graphics.Blit(src,dest, material); 
    }

    private void OnDestroy()
    {
       _buffer.Dispose(); 
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}

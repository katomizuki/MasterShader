using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShaderFind : MonoBehaviour
{
    private Material material;
    public Shader shader;

    private void Start()
    {
        // Shaderを指定してFindして取ってくる。
        material = new Material(Shader.Find("Hidden/ShaderFind"));

    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, material);
    }

    private void OnDisable()
    {

    }

    private void OnGUI()
    {
// GUILayout.Label(material, ? "SHADER IS FOUND" : "SHADER IS NOT FOUND");
    }
}

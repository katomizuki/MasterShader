using System;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

public class Command : MonoBehaviour
{
    [SerializeField] private Shader _shader;
    private void Awake()
    {
        Initialize();
    }

    private void Initialize()
    {
        // Cameraをイニシャライザ
        Camera camera = this.GetComponent<Camera>();
        // Material
        Material material = new Material(_shader);
        // commandBufferインスタンス化
        CommandBuffer commandBuffer = new CommandBuffer();
        // ラベル設定
        commandBuffer.name = "commandBuffer";
        // プロパティID
        int tempTextureIdentifier = Shader.PropertyToID("_PostEffectTemp");
        // 
        commandBuffer.GetTemporaryRT(tempTextureIdentifier, -1, -1);
        commandBuffer.Blit(BuiltinRenderTextureType.CameraTarget, tempTextureIdentifier);
        commandBuffer.Blit(tempTextureIdentifier, BuiltinRenderTextureType.CameraTarget, material);
        commandBuffer.ReleaseTemporaryRT(tempTextureIdentifier);
        camera.AddCommandBuffer(CameraEvent.BeforeImageEffects, commandBuffer);
    }
}

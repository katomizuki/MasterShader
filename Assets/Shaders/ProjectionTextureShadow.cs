using UnityEngine;

public class ProjectionTextureShadow : MonoBehaviour
{
    [Header("Setting")] [SerializeField] private Camera _camera;
    [SerializeField] private int _renderTextureSize = 521;
    [SerializeField] private Material _material;
    [SerializeField] private Transform _lightTransform;

    private int _matrixVpId;
    private int _textureId;
    private int _posId;
    private RenderTexture _renderTexture;
    
    private void Start()
    {
        SetPropertyId();
        CameraSettings();
    }

    private void SetPropertyId()
    {
        _matrixVpId = Shader.PropertyToID("_ShadowProjectorMatrixVP1");
        _textureId = Shader.PropertyToID("_ShadowProjectorTexture1");
        _posId = Shader.PropertyToID("_ShadowProjectorPos1");
    }

    private void CameraSettings()
    {
        _camera.depth = -10000;
        _camera.clearFlags = CameraClearFlags.Color;
        _camera.backgroundColor = Color.white;
        // 点滅を防ぐ
        // HDRを無効にする
        _camera.allowHDR = false;
    }

    private void OnPreRender()
    {
        if (_renderTexture == null)
        {
            UpdateSettings();
        }
        SetMaterialParams();
    }

    private void UpdateSettings()
    {
        ReleaseTexture();
        SetLightPosition();
        UpdateRenderTexture();
    }

    private void SetLightPosition()
    {
        var objTransform = transform;
        _lightTransform.position = objTransform.position;
        _lightTransform.rotation = objTransform.rotation;
    }

    private void UpdateRenderTexture()
    {
        // RenderTextureの更新を行なっている。
        _renderTexture = RenderTexture.GetTemporary(_renderTextureSize, 
            _renderTextureSize, 
            16,
            RenderTextureFormat.ARGB32);

        _camera.targetTexture = _renderTexture;
    }

    private void SetMaterialParams()
    {
        // カメラのビュー行列
        var viewMatrix = _camera.worldToCameraMatrix;
        // プロジェクション行列
        var projectionMatrix = GL.GetGPUProjectionMatrix(_camera.projectionMatrix, true);
        // 行列、テキスちゃをそれぞれセット
        _material.SetMatrix(_matrixVpId, projectionMatrix * viewMatrix);
        _material.SetTexture(_textureId, _renderTexture);
        // プロジェクターの座標を入れる　。
        _material.SetVector(_posId, GetProjectorPos());
    }

    private Vector4 GetProjectorPos()
    {
        Vector4 projectorPos;
        if (_camera.orthographic)
        {
            projectorPos = transform.forward;
            projectorPos.w = 0;
        }
        else
        {
            projectorPos = transform.position;
            projectorPos.w = 1;
        }
        return projectorPos;
    }

    private void ReleaseTexture()
    {
        // 解放
        _renderTexture.Release();
    }

    private void OnDestroy()
    {
        ReleaseTexture();
    }
}

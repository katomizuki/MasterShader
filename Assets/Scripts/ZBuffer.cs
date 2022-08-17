using UnityEngine;

public class ZBuffer : ImageEffectBase
{
    void Start()
    {
        // 深度だけ参照するときはDepth
        GetComponent<Camera>().depthTextureMode = DepthTextureMode.Depth;
        //base.Start();
    }
}

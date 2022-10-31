using UnityEngine;

public class MV : ImageEffectBase
{
    public override void Start()
    {
        GetComponent<Camera>().depthTextureMode = DepthTextureMode.Depth | DepthTextureMode.MotionVectors;
    }
}
